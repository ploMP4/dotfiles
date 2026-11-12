#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "result>=0.17",
#   "rich>=13",
# ]
# ///
"""feat — start work on a new feature branch.

Creates a git worktree at ../<name> on a new branch off main/master,
then creates and attaches a kuti session named after the branch.
"""

import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from result import Err, Ok, Result
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

console = Console(highlight=False)
errors = Console(stderr=True, highlight=False)

USAGE = "[bold]Usage:[/] [green]feat.py[/] [cyan]<name>[/]  [dim](feat.py --help for details)[/]"


@dataclass(frozen=True)
class CmdError:
    command: str
    detail: str


def run(args: list[str], cwd: Path | None = None) -> Result[str, CmdError]:
    pretty = " ".join(args)
    try:
        proc = subprocess.run(args, capture_output=True, text=True, cwd=cwd)
    except FileNotFoundError:
        return Err(CmdError(pretty, f"command not found: {args[0]}"))
    if proc.returncode != 0:
        detail = (
            proc.stderr.strip()
            or proc.stdout.strip()
            or f"exited with code {proc.returncode}"
        )
        return Err(CmdError(pretty, detail))
    return Ok(proc.stdout.strip())


def repo_root() -> Result[Path, CmdError]:
    return run(["git", "rev-parse", "--show-toplevel"]).map(Path)


def base_branch(root: Path) -> Result[str, CmdError]:
    for candidate in ("main", "master"):
        if isinstance(
            run(
                ["git", "rev-parse", "--verify", "--quiet", f"refs/heads/{candidate}"],
                cwd=root,
            ),
            Ok,
        ):
            return Ok(candidate)
    return Err(
        CmdError(
            "git rev-parse --verify refs/heads/{main,master}",
            "repository has neither a 'main' nor a 'master' branch",
        )
    )


def add_worktree(
    root: Path, dirname: str, branch: str, base: str
) -> Result[Path, CmdError]:
    path = root.parent / dirname
    if path.exists():
        return Err(
            CmdError(
                f"git worktree add {path}", f"target directory already exists: {path}"
            )
        )
    return run(["git", "worktree", "add", str(path), "-b", branch, base], cwd=root).map(
        lambda _: path
    )


def kuti_new(session: str, cwd: Path) -> Result[str, CmdError]:
    return run(["kuti", "new", session], cwd=cwd)


def kuti_attach(session: str, cwd: Path) -> Result[None, CmdError]:
    # attach is interactive: inherit the terminal instead of capturing output
    pretty = f"kuti attach {session}"
    try:
        proc = subprocess.run(["kuti", "attach", session], cwd=cwd)
    except FileNotFoundError:
        return Err(CmdError(pretty, "command not found: kuti"))
    if proc.returncode != 0:
        return Err(CmdError(pretty, f"exited with code {proc.returncode}"))
    return Ok(None)


def print_help() -> None:
    console.print(
        Panel.fit(
            "Start work on a new feature branch.\n\n"
            "[bold]Usage:[/] [green]feat.py[/] [cyan]<name>[/]\n\n"
            "[bold]Steps:[/]\n"
            "  [dim]1.[/] git worktree at [bold]../<name>[/] on new branch [bold]<name>[/] "
            "[dim](underscores become dashes)[/] off [bold]main[/] or [bold]master[/]\n"
            "  [dim]2.[/] [bold]kuti new[/] a session named after the branch\n"
            "  [dim]3.[/] [bold]kuti attach[/] to it\n\n"
            "[bold]Options:[/]\n"
            "  [cyan]-h[/], [cyan]--help[/]   show this help and exit",
            title="feat",
            border_style="dim",
        )
    )


def fail(step: str, error: CmdError) -> int:
    body = Text()
    body.append(f"$ {error.command}\n", style="bold dim")
    body.append(error.detail)
    errors.print(
        Panel(
            body, title=f"[bold red]✗ {step}[/]", title_align="left", border_style="red"
        )
    )
    return 1


def main(argv: list[str]) -> int:
    match argv:
        case ["-h"] | ["--help"]:
            print_help()
            return 0
        case []:
            errors.print(
                "[bold red]error:[/] missing required argument [cyan]<name>[/]"
            )
            errors.print(USAGE)
            return 2
        case [name] if not name.startswith("-"):
            pass
        case [flag]:
            errors.print(f"[bold red]error:[/] unknown option [cyan]{flag}[/]")
            errors.print(USAGE)
            return 2
        case _:
            errors.print(
                f"[bold red]error:[/] expected exactly one argument, got {len(argv)}"
            )
            errors.print(USAGE)
            return 2

    branch = name.replace("_", "-")

    match repo_root():
        case Ok(root):
            pass
        case Err(error):
            return fail("not inside a git repository", error)

    match base_branch(root):
        case Ok(base):
            pass
        case Err(error):
            return fail("no base branch", error)

    match add_worktree(root, name, branch, base):
        case Ok(worktree):
            console.print(
                f"[green]✓[/] worktree [bold]{worktree}[/] [dim](branch {branch} off {base})[/]"
            )
        case Err(error):
            return fail("could not create worktree", error)

    match kuti_new(branch, worktree):
        case Ok(_):
            console.print(f"[green]✓[/] kuti session [bold]{branch}[/]")
        case Err(error):
            return fail("could not create kuti session", error)

    console.print(f"[green]→[/] attaching [bold]{branch}[/]")
    match kuti_attach(branch, worktree):
        case Err(error):
            return fail("could not attach kuti session", error)

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        sys.exit(130)
