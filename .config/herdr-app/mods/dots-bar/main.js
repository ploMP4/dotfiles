// The top bar of the "dots" layouts. Colors come from theme(), so the wallust
// theme re-tints it with the wallpaper.
//
//   props.variant "full" (default, layout dots):  [ 󰤂 space ▾ ] tabs …  others  branch  files changes  +
//   props.variant "tabs" (layout dots-sidebar):   tabs …  others  branch  files changes  +
//                                                 (the sidebar already shows the spaces)
//
// Tabs are named like tmux's automatic-rename ("claude", "zsh", "codex") with
// the program's icon; the shown one gets the wallpaper gradient underline
// (accent -> secondary, like Hyprland's active border). Status: braille spinner
// while working, a pulsing red dot when blocked, a green dot when finished.
// Mouse: pill = sessions, tab = select, double-click = rename, right-click = tab
// menu, wheel = previous/next tab, + = new terminal/agent.
//
// Commands (keys.json):
//   nav-left/-down/-up/-right  ctrl+h/j/k/l like vim-tmux-navigator: Neovim/fzf
//     get the key themselves (nvim hands back to Herdr at its edge, see
//     ~/.config/nvim/lua/custom/plugins/tmux-navigator.lua), a pane alone in
//     its tab gets it too (ctrl+l still clears), else focus moves to the
//     Herdr pane in that direction.
//   spaces / agents / projects  open the switch popup in that mode.
//   sidebar-collapse     fold the sidebar to its icon rail / unfold it.

import { View, div, svg, image, PathBuilder, Background } from "gpui-kit";
import { h_flex } from "gpui-base";
import {
  spaces, panes, focused, layout, run, hc, nextCommand, theme, settings, props, openOverlay, closeOverlay,
  shared, setShared, window as appWindow,
} from "herdr";

const SPIN = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

const NAV = {
  "nav-left": ["left", "ctrl+h"],
  "nav-down": ["down", "ctrl+j"],
  "nav-up": ["up", "ctrl+k"],
  "nav-right": ["right", "ctrl+l"],
};
// vim-tmux-navigator's is_vim list: programs that use ctrl+hjkl themselves.
const OWNS_NAV = /^(g?view|n?vim?x?|fzf)$/;

async function navigate(direction, key) {
  const f = focused();
  const pane = f?.pane ? panes().find((p) => p.pane === f.pane) : null;
  const g = pane?.program;
  const ownsNav = [g?.key, g?.name?.toLowerCase()].some((n) => n && OWNS_NAV.test(n));
  const alone = pane && panes().filter((p) => p.tab === pane.tab).length < 2;
  if (f?.terminal && (ownsNav || alone)) await hc(["keys", f.terminal, key]);
  else run("pane.go", { direction });
}

// sidebar-collapse: the sidebar to its icon rail and back, exactly like the
// button in Herdr's workspace-chrome (same shared keys, so the two agree).
function toggleRail() {
  const sidebar = find(layout(), "sidebar");
  if (!sidebar) return;
  if (sidebar.hidden) return run("layout.show", { id: "sidebar" });
  const narrow = (sidebar.size?.px ?? Infinity) < 160;
  if (!narrow) setShared("sidebar.width", sidebar.size?.px);
  setShared("sidebar.collapsed", !narrow);
  run("layout.resize", { id: "sidebar", px: narrow ? (shared("sidebar.width") ?? 264) : appWindow()?.platform === "macos" ? 76 : 44 });
}

const SWITCH = { mod: "switch", kind: "popup", at: "top", offset: 48, width: 1100, height: 0.8 };

function find(node, id) {
  if (!node || typeof node !== "object") return null;
  if (node.id === id) return node;
  for (const c of node.children ?? []) {
    const hit = find(c, id);
    if (hit) return hit;
  }
  return null;
}

// What tmux's automatic-rename would call a tab: the program in it, agent first
// ("claude", "codex", "zsh", "nvim"), unless someone named the tab.
function lead(tab, all) {
  const mine = all.filter((p) => p.tab === tab.id);
  return mine.find((p) => p.program?.agent) ?? mine.find((p) => p.focused) ?? mine[0];
}
function tabName(tab, p) {
  if (tab.named) return tab.name;
  const g = p?.program;
  if (!g) return tab.name;
  if (["shell", "program", "agent"].includes(g.key)) return (g.name || tab.name).toLowerCase();
  return g.key;
}

function icon(g, color, size = 14) {
  if (!g?.icon) return null;
  return g.tint ? svg(g.icon).size(size).flex_none().text_color(color) : image(g.icon).size(size).flex_none();
}

// A full-size layer painted with a gradient (the parent must be relative).
const RECT = () =>
  PathBuilder.fill().move_to("0%", "0%").line_to("100%", "0%").line_to("100%", "100%").line_to("0%", "100%").close().build();
function gradient(from, to, angle = 90) {
  return window.paint_path(RECT(), Background.linear_gradient(angle, from, to)).absolute().top(0).left(0).size_full();
}

// A control in the draggable bar owns its press (the window doesn't move).
const own = (el) =>
  el.on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_mouse_down("right", (_e, cx) => cx.stop_propagation());

// The status mark after a name, or null (callers add it with `mark`, since
// child(null) is an error).
function glyph(t, status) {
  if (status === "working") return div().flex_none().text_color(t.working).frames(SPIN, 90);
  if (status === "blocked")
    return div().flex_none().size(7).rounded_full().bg(t.blocked).loop("opacity", { from: 0.3, to: 1, period: 1100 });
  if (status === "done") return div().flex_none().size(7).rounded_full().bg(t.done);
  return null;
}
const mark = (el, node) => (node ? el.child(node) : el);
// #rrggbb + alpha (theme colors may already carry one).
const alpha = (c, aa) => (c ?? "#000000").slice(0, 7) + aa;

export default class DotsBar extends View {
  init(_props, cx) {
    this.overlay = null;
    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        try {
          if (NAV[c]) await navigate(...NAV[c]);
          else if (["spaces", "agents", "projects", "sessions"].includes(c)) this.openSwitch(c === "sessions" ? "spaces" : c);
          else if (c === "sidebar-collapse") toggleRail();
        } catch (e) {
          console.log(`dots-bar ${c}: ${e?.message ?? e}`);
        }
        cx.notify();
      }
    });
  }

  openSwitch(mode) {
    if (this.overlay) closeOverlay(this.overlay);
    this.overlay = openOverlay({ ...SWITCH, props: { mode } });
  }

  render() {
    const t = theme();
    const all = panes();
    const list = spaces();
    const space = list.find((s) => s.active);
    const full = (props()?.variant ?? "full") === "full";
    const s = settings();
    const size = Math.max(13, Math.min(16, (s.font_size ?? 15) - 2));
    const accent2 = t.working; // the wallust theme's secondary accent
    const bar = h_flex()
      .id("dots-bar")
      .relative()
      .size_full()
      .min_w(0)
      .px(full ? 4 : 8)
      .py(4)
      .gap(4)
      .items_center()
      .bg(t.chrome)
      .font_family(s.font_family ?? "ZedMono Nerd Font")
      .text_size(size)
      // a hairline under the bar, fading out from the accent
      .child(div().absolute().left(0).right(0).bottom(0).h(1).child(gradient(alpha(t.accent, "99"), alpha(t.accent, "00"))));
    if (!space) return bar;

    const pill = own(h_flex())
      .id("dots-space")
      .flex_none()
      .h_full()
      .pl(10)
      .pr(8)
      .gap(7)
      .items_center()
      .rounded(6)
      .bg(t.accent)
      .text_color(t.accent_foreground)
      .font_bold()
      .cursor_pointer()
      .shadow_sm()
      .on_click(() => this.openSwitch("spaces"))
      .child(div().flex_none().child("󰤂"))
      .child(div().max_w(220).truncate().child(space.name))
      .child(div().flex_none().opacity(0.65).child("▾"));

    const tab = (c) => {
      const p = lead(c, all);
      const status = c.active && c.status === "done" ? null : c.status;
      const el = h_flex()
        .id(`dots-tab-${c.id}`)
        .relative()
        .flex_shrink(1)
        .min_w(0)
        .h_full()
        .px(10)
        .gap(7)
        .items_center()
        .rounded(6)
        .cursor_pointer()
        .when(c.active, (e) => e.bg(t.raised).text_color(t.foreground).font_bold())
        .when(!c.active, (e) => e.text_color(t.muted).hover((st) => st.bg(t.hover).text_color(t.foreground)))
        .on_mouse_down("left", (e, cx) => {
          cx.stop_propagation();
          if (e.click_count === 2) run("tab.rename", { id: c.id });
        })
        .on_click(() => run("tab.select", { id: c.id }))
        .on_mouse_down("right", (_e, cx) => {
          cx.stop_propagation();
          openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } });
        })
        .child(div().flex_none().text_size(size - 2).text_color(c.active ? t.accent : t.dim).child(String(c.index)));
      return mark(
        mark(el, icon(p?.program, c.active ? t.accent : t.dim))
          .child(div().min_w(0).truncate().child(tabName(c, p) + (c.zoomed ? "  󰁌" : "")))
          .when(c.active, (e) =>
            e.child(div().absolute().left(8).right(8).bottom(0).h(2).rounded_full().overflow_hidden().child(gradient(t.accent, accent2))),
          ),
        glyph(t, status),
      );
    };

    // Other spaces with something going on: blocked first, then finished, then busy.
    const rank = { blocked: 0, done: 1, working: 2 };
    const others = list
      .filter((x) => !x.active && rank[x.status] !== undefined)
      .sort((a, b) => rank[a.status] - rank[b.status]);
    const other = (x) =>
      mark(
        own(h_flex())
          .id(`dots-other-${x.id}`)
          .flex_none()
          .h_full()
          .px(9)
          .gap(7)
          .items_center()
          .rounded(6)
          .border_1()
          .border_color(x.status === "working" ? t.border : alpha(t[x.status], "66"))
          .cursor_pointer()
          .text_size(size - 1)
          .text_color(x.status === "working" ? t.muted : t[x.status])
          .hover((st) => st.bg(t.hover))
          .on_click(() => run("space.select", { id: x.id }))
          .child(div().max_w(150).truncate().child(x.name)),
        glyph(t, x.status),
      );

    // Files / Changes panel toggles (the layout's "panel" stack), as in Herdr's tab bar.
    const root = layout();
    const panel = find(root, "panel");
    const body = find(root, "panel-body");
    const panelButton = (id, path) => {
      const on = panel && !panel.hidden && body?.active === id;
      return own(div())
        .id(`dots-panel-${id}`)
        .flex_none()
        .size(26)
        .flex()
        .items_center()
        .justify_center()
        .rounded(6)
        .cursor_pointer()
        .when(on, (e) => e.bg(t.selected).text_color(t.accent))
        .when(!on, (e) => e.text_color(t.dim).hover((st) => st.bg(t.hover).text_color(t.foreground)))
        .on_click(() => {
          if (on) run("layout.hide", { id: "panel" });
          else {
            run("layout.select", { stack: "panel-body", child: id });
            run("layout.show", { id: "panel" });
          }
        })
        .child(svg(path).size(15));
    };

    return bar
      .on_scroll_wheel((e) => {
        if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next");
      })
      .when(full, (e) => e.child(pill).child(div().flex_none().w(4)))
      .child(h_flex().flex_1().min_w(0).h_full().gap(2).items_center().children(space.tabs.filter((c) => !c.settled).map(tab)))
      .children(others.map(other))
      .when(Boolean(space.branch), (e) =>
        e.child(
          h_flex()
            .flex_none()
            .px(8)
            .gap(6)
            .items_center()
            .text_size(size - 2)
            .text_color(t.dim)
            .child(div().text_color(accent2).child(""))
            .child(div().max_w(220).truncate().child(space.branch)),
        ),
      )
      .when(Boolean(panel && body), (e) =>
        e.child(panelButton("files", "mods/files/file.svg")).child(panelButton("changes", "mods/changes/changes.svg")),
      )
      .child(
        own(div())
          .id("dots-new")
          .flex_none()
          .size(26)
          .flex()
          .items_center()
          .justify_center()
          .rounded(6)
          .text_color(t.dim)
          .cursor_pointer()
          .hover((st) => st.bg(t.hover).text_color(t.foreground))
          .on_click(() => openOverlay({ mod: "new-menu", kind: "popup", width: 250, height: 512 }))
          .child("+"),
      );
  }
}
