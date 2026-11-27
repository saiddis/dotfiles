# dotfiles

My [Omarchy](https://omarchy.org) desktop: Hyprland bindings and look, the
Omarchy shell (bar, my own plugins, lock screen), the Moonfly theme, Neovim
(LazyVim), Ghostty, herdr, fcitx5 English/Russian, and a few scripts.

## Install

On an Omarchy machine:

```sh
git clone https://github.com/saiddis/dotfiles ~/dotfiles
~/dotfiles/install --dry-run   # what it would do
~/dotfiles/install
```

`install` is safe to run again; whatever is already in place is left alone.
It adds the packages in `setup/packages.txt`, links the configs below with
GNU stow (anything already in the way is moved to
`~/.local/state/dotfiles/backup/<time>/`), clones the other people's Omarchy
plugins and themes listed in `setup/`, turns on the device-notify service,
installs Neovim's plugins at the versions in `lazy-lock.json`, and sets the
Moonfly theme.

Keyboard remaps need root and are a separate step:
`evremap/install-systemd.sh`.

`./doctor` checks that everything is still linked and lists what changed in
the repo.

## Layout

Each top-level folder is a stow package, mirroring `$HOME`.

| Package | What |
|---|---|
| `omarchy` | `~/.config/omarchy`: shell settings (`shell.json`), menu, hooks, my plugins (`saiddis.*`: keyboard layout, lock screen, notifications), the Moonfly theme |
| `hypr` | `~/.config/hypr`: bindings, input, look and feel, monitors |
| `nvim` | `~/.config/nvim`: LazyVim with my plugins (sessions, diagnostics, bento, Strudel, ...) |
| `ghostty` `alacritty` `kitty` `foot` | terminal settings (Omarchy themes their colours) |
| `fcitx5` | English/Russian input, switched with Alt+Shift |
| `fontconfig` `mise` `starship` | monospace font, dev tools, prompt |
| `herdr` | the terminal multiplexer |
| `bin` | `device-notify` (USB/Bluetooth connect notices) and its user service, the keybinding menus |
| `evremap` | keyboard remaps (system service, see above) |
| `agents` `claude` `codex` | global agent rules (`~/.agents/AGENTS.md`, which Claude Code and Codex read) and Claude Code settings; tstack skills are linked from `~/tstack` |
| `legacy/` | the pre-Omarchy i3/Hyprland setup, kept for reference; never linked |

Most packages link the whole `~/.config/<name>` folder rather than each file:
Omarchy's shell, Qt apps, fcitx5 and `sed -i` save by writing a new file and
renaming it over the old one, which would turn a linked file back into a
plain copy. With the folder linked, those saves land here and show up in
`git status`.

Other people's plugins and themes are cloned into the linked folders but
ignored by git; they're listed in `setup/omarchy-plugins.txt` and
`setup/omarchy-themes.txt`.

Not in this repo: git's config (my email), superwhisper's settings (cloud
credentials), and app state.

## Moonfly

`omarchy/.config/omarchy/themes/moonfly` is the theme as I use it. The
published version, for `omarchy theme install`, is
[omarchy-moonfly-theme](https://github.com/saiddis/omarchy-moonfly-theme),
exported from it with `setup/export-moonfly`.
