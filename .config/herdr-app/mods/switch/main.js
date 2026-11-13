// Switch: the Herdr side of `tms switch` / `tms`, with a preview like tms.
//
//   Spaces    (prefix s)    just the spaces, by name; the preview shows the
//                           screen of the tab each one is on.
//   Agents    (prefix w)    every agent, the ones with something to tell you
//                           first: needs you > finished > working > idle;
//                           the preview shows what it's saying.
//   Projects  (prefix C-o)  git repos under ~/.config/tms/config.toml's
//                           search_dirs (each to its depth, like tms): Enter
//                           goes to the space already there, or opens one.
//                           The preview shows git status and recent commits.
//
// props.mode picks the first mode ("spaces" by default); Tab / Shift-Tab cycle.
// Type to filter; ↑/↓ or ctrl-n/ctrl-p (ctrl-j/ctrl-k) to move; Enter to go;
// Esc to leave. The preview is plain text (`hc read`), refreshed every second.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, ScrollHandle } from "gpui-base";
import { spaces, panes, agents, run, exec, hc, home, readTextFile, theme, settings, props, closeOverlay } from "herdr";

const MODES = ["spaces", "agents", "projects"];
const TITLE = { spaces: "Spaces", agents: "Agents", projects: "Projects" };
const SPIN = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const SKIP = ["node_modules", ".venv", "venv", "target", ".cache", "vendor", "dist"];
const RANK = { blocked: 0, done: 1, working: 2, idle: 3 };
const SAYS = { blocked: "needs you", done: "finished", working: "working", idle: "idle" };
const LIST_H = 400;
const LINE_H = 15;

// The [[search_dirs]] tables of tms' config: { path, depth }.
function searchDirs(toml, h) {
  const out = [];
  for (const block of (toml ?? "").split(/^\s*\[\[search_dirs\]\]\s*$/m).slice(1)) {
    const path = block.match(/^\s*path\s*=\s*"([^"]+)"/m)?.[1];
    const depth = Number(block.match(/^\s*depth\s*=\s*(\d+)/m)?.[1] ?? 10);
    if (path) out.push({ path: path.replace(/^~(?=\/|$)/, h), depth });
  }
  return out.length ? out : [{ path: h, depth: 2 }];
}

// 0: starts with q, 1: contains it, 2: its letters in order; null: no match.
function score(q, name, rest = "") {
  if (!q) return 0;
  const n = name.toLowerCase();
  if (n.startsWith(q)) return 0;
  if (n.includes(q)) return 1;
  let i = 0;
  for (const ch of `${n} ${rest.toLowerCase()}`) if (ch === q[i]) i++;
  return i === q.length ? 2 : null;
}

const tilde = (path, h) => (path === h ? "~" : path?.startsWith(h + "/") ? "~" + path.slice(h.length) : path ?? "");

function ago(ms) {
  if (!ms) return "";
  const s = Math.max(0, Math.round((Date.now() - ms) / 1000));
  return s < 60 ? `${s}s` : s < 3600 ? `${Math.floor(s / 60)}m` : `${Math.floor(s / 3600)}h`;
}

function glyph(t, status) {
  if (status === "working") return div().flex_none().w(10).text_color(t.working).frames(SPIN, 90);
  if (status === "blocked")
    return div().flex_none().size(7).mx(1.5).rounded_full().bg(t.blocked).loop("opacity", { from: 0.3, to: 1, period: 1100 });
  if (status === "done") return div().flex_none().size(7).mx(1.5).rounded_full().bg(t.done);
  return div().flex_none().size(7).mx(1.5).rounded_full().border_1().border_color(t.dim);
}

function icon(g, color) {
  if (!g?.icon) return div().flex_none().w(14);
  return g.tint ? svg(g.icon).size(14).flex_none().text_color(color) : image(g.icon).size(14).flex_none();
}

// The terminal a space is showing: the focused pane of its shown tab, else its agent, else the first.
function shownTerminal(space) {
  const tab = space.tabs.find((c) => c.active) ?? space.tabs[0];
  const mine = panes().filter((p) => p.tab === tab?.id && p.terminal);
  return (mine.find((p) => p.focused) ?? mine.find((p) => p.program?.agent) ?? mine[0])?.terminal ?? null;
}

export default class Switch extends View {
  init(_props, cx) {
    this.mode = MODES.includes(props()?.mode) ? props().mode : "spaces";
    this.repos = null;
    this.error = null;
    this.filter = "";
    this.at = null;
    this.preview = { key: null, lines: null };
    this.handle = cx.focus_handle();
    this.scroll = ScrollHandle.new();
    this.input = InputState.new({ placeholder: "Type to filter…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      this.refresh(cx);
    });
    this.input.on("submit", () => this.go(this.rows()[this.at ?? 0]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    // Live-ish preview: reread the selected terminal every second while open.
    cx.timer.every(1000, (cx) => this.refresh(cx, true));
    cx.spawn(async (cx) => {
      try {
        await this.scan();
      } catch (e) {
        this.error = String(e?.message ?? e);
      }
      this.refresh(cx);
    });
    this.refresh(cx);
  }

  cycle(d, cx) {
    this.mode = MODES[(MODES.indexOf(this.mode) + d + MODES.length) % MODES.length];
    this.at = null;
    this.input.focus();
    this.refresh(cx);
  }

  async scan() {
    const h = home();
    const dirs = searchDirs(await readTextFile(`${h}/.config/tms/config.toml`), h);
    const prune = SKIP.flatMap((n, i) => (i ? ["-o", "-name", n] : ["-name", n]));
    const found = await Promise.all(
      dirs.map((d) =>
        exec("find", [d.path, "-maxdepth", String(d.depth + 1), "(", ...prune, ")", "-prune", "-o", "-name", ".git", "-printf", "%h\\n", "-prune"], { timeout: 15000 })
          .then((r) => r.stdout.split("\n").filter(Boolean))
          .catch(() => []),
      ),
    );
    const seen = new Set();
    this.repos = found
      .flat()
      .filter((p) => !seen.has(p) && seen.add(p))
      .map((path) => ({ path, name: path.split("/").pop(), where: tilde(path, h) }));
  }

  // The space already in this repo: one started there, else one with a terminal inside it.
  spaceFor(path) {
    const list = spaces().filter((s) => !s.machine);
    const inside = (cwd) => cwd === path || cwd?.startsWith(path + "/");
    return (
      list.find((s) => s.folder === path) ??
      list.find((s) => panes().some((p) => inside(p.cwd) && s.tabs.some((c) => c.id === p.tab)))
    );
  }

  rows() {
    const q = this.filter.trim().toLowerCase();
    if (this.mode === "spaces") {
      return spaces()
        .map((s) => ({ kind: "space", space: s, score: score(q, s.name) }))
        .filter((r) => r.score !== null)
        .sort((a, b) => a.score - b.score);
    }
    if (this.mode === "agents") {
      const tabs = new Map(spaces().flatMap((s) => s.tabs.map((c) => [c.id, c])));
      return agents()
        .map((a) => ({ kind: "agent", agent: a, since: tabs.get(a.tab)?.working_since, score: score(q, a.program?.name ?? "", `${a.space_name} ${a.tab_name} ${a.title}`) }))
        .filter((r) => r.score !== null)
        .sort((x, y) => x.score - y.score || RANK[x.agent.status] - RANK[y.agent.status] || y.agent.pinned - x.agent.pinned || y.agent.seq - x.agent.seq);
    }
    return (this.repos ?? [])
      .map((r) => ({ kind: "repo", ...r, space: this.spaceFor(r.path), score: score(q, r.name, r.where) }))
      .filter((r) => r.score !== null)
      .sort((a, b) => a.score - b.score || Boolean(b.space) - Boolean(a.space) || a.name.localeCompare(b.name));
  }

  // What the preview shows for a row: a terminal's screen, or a repo's git state.
  target(r) {
    if (!r) return null;
    if (r.kind === "space") {
      const term = shownTerminal(r.space);
      return term ? { key: `t:${term}`, terminal: term } : null;
    }
    if (r.kind === "agent") return { key: `t:${r.agent.address}`, terminal: r.agent.address };
    return { key: `g:${r.path}`, repo: r.path };
  }

  // Load the preview for the selected row. `again`: the timer's reread, terminals only.
  refresh(cx, again = false) {
    const rows = this.rows();
    const at = this.at ?? this.startAt(rows);
    const want = this.target(rows[Math.max(0, Math.min(at, rows.length - 1))]);
    if (!want) {
      this.preview = { key: null, lines: null };
      return cx.notify();
    }
    if (again && (want.key !== this.preview.key || !want.terminal)) return;
    if (!again && want.key === this.preview.key) return cx.notify();
    if (!again) this.preview = { key: want.key, lines: null };
    cx.notify();
    cx.spawn(async (cx) => {
      let lines;
      try {
        if (want.terminal) {
          const r = await hc(["read", want.terminal]);
          lines = r.code === 0 ? r.stdout.replace(/\s+$/, "").split("\n") : [r.stderr.trim() || "can't read this terminal"];
        } else {
          const [st, log] = await Promise.all([
            exec("git", ["-C", want.repo, "status", "-sb"], { timeout: 5000 }),
            exec("git", ["-C", want.repo, "log", "--oneline", "--decorate", "-n", "40"], { timeout: 5000 }),
          ]);
          lines = [...st.stdout.replace(/\s+$/, "").split("\n").slice(0, 12), "", ...log.stdout.replace(/\s+$/, "").split("\n")];
        }
      } catch (e) {
        lines = [String(e?.message ?? e)];
      }
      if (this.preview.key !== want.key) return; // moved on meanwhile
      this.preview = { key: want.key, lines, top: Boolean(want.repo) };
      cx.notify();
    });
  }

  startAt(rows) {
    if (this.mode === "spaces") return Math.max(0, rows.findIndex((r) => r.space.active));
    return 0;
  }

  go(r) {
    if (!r) return;
    closeOverlay(props().overlay);
    if (r.kind === "space") run("space.select", { id: r.space.id });
    else if (r.kind === "agent") run("agent.focus", { terminal: r.agent.address });
    else if (r.space) run("space.select", { id: r.space.id });
    else run("space.new", { folder: r.path });
  }

  render() {
    const t = theme();
    const h = home();
    const mono = settings().font_family ?? "ZedMono Nerd Font";
    const rows = this.rows();
    if (this.at === null) this.at = this.startAt(rows);
    this.at = Math.max(0, Math.min(this.at, rows.length - 1));
    const move = (d, cx) => {
      if (!rows.length) return;
      this.at = (this.at + d + rows.length) % rows.length;
      this.scroll.scroll_to_item(this.at);
      this.refresh(cx);
    };

    const base = (r, i) =>
      h_flex()
        .id(`sw-${i}`)
        .flex_none()
        .px(10)
        .gap(10)
        .items_center()
        .rounded(6)
        .cursor_pointer()
        .when(i === this.at, (el) => el.bg(t.selected))
        .when(i !== this.at, (el) => el.hover((s) => s.bg(t.hover)))
        .on_click(() => this.go(r));

    const row = (r, i) => {
      if (r.kind === "space") {
        const s = r.space;
        return base(r, i)
          .h(34)
          .child(
            h_flex()
              .flex_none()
              .size(22)
              .rounded(6)
              .items_center()
              .justify_center()
              .bg(s.active ? t.accent : t.raised)
              .text_color(s.active ? t.accent_foreground : t.muted)
              .font_family(mono)
              .font_bold()
              .text_size(12)
              .child([...s.name][0]?.toUpperCase() ?? "?"),
          )
          .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).when(s.active, (d) => d.font_semibold()).child(s.name));
      }
      if (r.kind === "agent") {
        const a = r.agent;
        const says = a.status === "working" && r.since ? `working ${ago(r.since)}` : SAYS[a.status];
        return base(r, i)
          .h(44)
          .child(glyph(t, a.status))
          .child(icon(a.program, t.muted))
          .child(
            v_flex()
              .flex_1()
              .min_w(0)
              .child(div().truncate().text_color(t.foreground).font_semibold().child(a.program?.name ?? a.app ?? "agent"))
              .child(div().truncate().text_size(11.5).text_color(t.dim).child(`${a.space_name} · ${a.tab_name}${a.title ? ` · ${a.title}` : ""}`)),
          )
          .child(
            div()
              .flex_none()
              .text_size(11)
              .text_color(a.status === "blocked" ? t.blocked : a.status === "done" ? t.done : t.dim)
              .when(a.status === "blocked" || a.status === "done", (d) => d.font_semibold())
              .child(says),
          );
      }
      return base(r, i)
        .h(32)
        .child(div().w(8).flex_none().text_color(r.space ? t.accent : t.dim).child(r.space ? "●" : ""))
        .child(div().flex_none().max_w(200).truncate().text_color(t.foreground).when(Boolean(r.space), (d) => d.font_semibold()).child(r.name))
        .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.dim).child(r.where));
    };

    const segment = (mode) =>
      div()
        .id(`sw-mode-${mode}`)
        .px(10)
        .py(3)
        .rounded(5)
        .cursor_pointer()
        .text_size(12)
        .when(this.mode === mode, (el) => el.bg(t.accent).text_color(t.accent_foreground).font_semibold())
        .when(this.mode !== mode, (el) => el.text_color(t.muted).hover((s) => s.text_color(t.foreground)))
        .on_click((_e, cx) => this.cycle(MODES.indexOf(mode) - MODES.indexOf(this.mode), cx))
        .child(TITLE[mode]);

    let summary = "";
    if (this.mode === "agents") {
      const all = agents();
      const n = (st) => all.filter((a) => a.status === st).length;
      summary = [[n("blocked"), "need you"], [n("done"), "finished"], [n("working"), "working"]]
        .filter(([c]) => c)
        .map(([c, w]) => `${c} ${w}`)
        .join(" · ") || `${all.length} agents, all idle`;
    } else if (this.mode === "spaces") summary = `${spaces().length} spaces`;
    else summary = this.repos ? `${this.repos.length} repos · tms search_dirs` : "tms search_dirs";

    const empty =
      this.mode === "spaces"
        ? "No space matches"
        : this.mode === "agents"
          ? agents().length ? "No agent matches" : "No agents running"
          : this.error
            ? `Couldn't scan: ${this.error}`
            : this.repos === null
              ? "Looking for repos…"
              : "No project matches";

    const lines = this.preview.lines;
    const preview = v_flex()
      .flex_1()
      .min_w(0)
      .h(LIST_H)
      .p(10)
      .rounded(7)
      .border_1()
      .border_color(t.border)
      .bg(t.background)
      .overflow_hidden()
      .font_family(mono)
      .text_size(11.5)
      .text_color(t.muted)
      // terminals: keep the bottom (where the prompt / question is); git: the top
      .when(!this.preview.top, (el) => el.justify_end())
      .children(
        lines === null
          ? [div().text_color(t.dim).child(this.preview.key ? "…" : "nothing to preview")]
          : lines.slice(-120).map((l) => div().flex_none().h(LINE_H).truncate().child(l.length ? l : " ")),
      );

    const hint = (k, what) =>
      h_flex().gap(5).items_center().child(div().px(5).rounded(4).bg(t.raised).text_color(t.muted).font_family(mono).child(k)).child(what);

    return v_flex()
      .id("switch")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(14)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        const ctrl = e.modifiers.control;
        if (k === "escape") return closeOverlay(props().overlay);
        if (k === "tab") this.cycle(e.modifiers.shift ? -1 : 1, cx);
        else if (k === "down" || (ctrl && (k === "n" || k === "j"))) move(1, cx);
        else if (k === "up" || (ctrl && (k === "p" || k === "k"))) move(-1, cx);
        else return;
        cx.stop_propagation();
      })
      .child(
        h_flex()
          .items_center()
          .gap(8)
          .child(h_flex().p(3).gap(2).rounded(7).bg(t.background).children(MODES.map(segment)))
          .child(div().flex_1())
          .child(div().text_size(11).text_color(this.mode === "agents" && agents().some((a) => a.status === "blocked") ? t.blocked : t.dim).child(summary)),
      )
      .child(
        h_flex()
          .h(36)
          .flex_none()
          .px(10)
          .gap(8)
          .items_center()
          .rounded(7)
          .border_1()
          .border_color(t.accent)
          .bg(t.background)
          .child(div().text_color(t.accent).font_family(mono).child(this.mode === "spaces" ? "󰤂" : this.mode === "agents" ? "󰚩" : ""))
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(
        h_flex()
          .gap(10)
          .items_start()
          .child(
            v_flex()
              .w(360)
              .flex_none()
              .h(LIST_H)
              .child(
                rows.length
                  ? v_flex().id(`sw-list-${this.mode}`).max_h(LIST_H).overflow_y_scroll().track_scroll(this.scroll).children(rows.map(row))
                  : div().px(10).py(8).text_color(t.dim).child(empty),
              ),
          )
          .child(preview),
      )
      .child(
        h_flex()
          .gap(14)
          .text_size(11)
          .text_color(t.dim)
          .child(hint("↑↓", "move"))
          .child(hint("⏎", this.mode === "agents" ? "jump to it" : "go"))
          .child(hint("⇥", "next list"))
          .child(hint("esc", "close")),
      );
  }
}
