# What ./install links and ./doctor checks. Sourced, not run.

# Stow packages (folders at the top of this repo), in install order
PACKAGES=(omarchy hypr nvim ghostty alacritty kitty foot fcitx5 fontconfig mise starship herdr bin evremap)

# Packages whose ~/.config folder is one link to this repo rather than a
# link per file. Omarchy's shell, Qt apps, fcitx5 and `sed -i` save a file by
# writing a new one and renaming it over the old: a linked file would quietly
# turn back into a plain copy. With the folder linked, the new file lands in
# the repo and shows up in `git status`.
FOLDED=(omarchy hypr nvim ghostty alacritty kitty foot fcitx5 fontconfig mise evremap)

# Links Omarchy expects that can't live in git (they point into ~/.local)
NVIM_THEME_LINK="$HOME/.config/nvim/lua/plugins/theme.lua"
NVIM_THEME_TARGET="$HOME/.local/state/omarchy/current/theme/neovim.lua"
