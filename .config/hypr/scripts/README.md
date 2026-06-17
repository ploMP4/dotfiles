# Wallpaper theming pipeline

Animated wallpapers ([phonto]) drive a single accent palette that is applied,
live, across the whole desktop. Picking a wallpaper crossfades it and re-themes
everything in sync.

## Flow

```
MOD+B ─▶ quickshell picker ─▶ set-wallpaper.sh <file>
                                   │
                 ┌─────────────────┴───────────────────┐
                 ▼                                       ▼
   wallust-apply.sh --generate <file>        phonto <file>  (crossfade)
        │  (ffmpeg frame ─▶ wallust ─▶ cache)
        ▼
   wallust-colors.py   normalise bg, derive primary/secondary accent,
        │              write every app's colour file
        ▼
   wallust-apply.sh --apply   reload/animate ghostty, hyprland, waybar,
                              neovim, tmux, tms
```

## Scripts

| File | Role |
| --- | --- |
| `set-wallpaper.sh` | Switch wallpaper + crossfade + theme. Takes a path or `--shuffle`. |
| `wallust-apply.sh` | Orchestrator: `--generate` (compute colours, cached), `--apply` (reloads), `--prewarm-all` (cache every wallpaper at login). |
| `wallust-colors.py` | Derives the accent from the wallpaper background and writes each app's colour file. Tuning knobs at the top. |
| `wallpaper-list.sh` | Lists wallpapers + thumbnails for the picker. |

The picker UI is `~/.config/quickshell/wallpaper/shell.qml`.

## Generated outputs (do not edit by hand)

`~/.cache/wallust/accent` · `~/.config/ghostty/wallust` · `~/.config/wofi/style.css`
· `~/.config/waybar/style.css` · `~/.cache/wallust/{p10k-accent.zsh,tmux.conf}` ·
`~/.config/stochos/config.toml` `[colors]`. Edit the matching `*.in` templates
or `wallust-colors.py` instead.

## Dependencies

`wallust`, `ffmpeg`, `quickshell` (Qt6 + qt6-multimedia), `phonto`, `hyprland`,
`waybar`, `wofi`, `tmux` + `tms`, `stochos`. The neovim side lives in the
`lumonight` colorscheme, which reads `~/.cache/wallust/accent`.

## Tips

- Add wallpapers to `~/dotfiles/wallpapers/animated/`; the picker thumbnails and
  colour cache build on first sight (or run `wallust-apply.sh --prewarm-all`).
- After changing a template or `wallust-colors.py`, clear the cache:
  `rm -f ~/.cache/wallust/palettes/*`.

[phonto]: https://github.com/museslabs/phonto
