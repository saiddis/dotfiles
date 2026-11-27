#!/usr/bin/env python3
"""Rebuild Moonfly's override files from colors.toml, then apply the theme.

The look: stock moonfly colours, flat and quiet. Near-black canvas, neutral
greys, one accent (moonfly blue) for focus and selection, rounded windows with
soft shadows, and opaque floating surfaces with hairline edges.

This theme ships its own shell.toml, t3code.json, hyprland.lua and terminal
configs (ghostty.conf, alacritty.toml, kitty.conf, foot.ini) because they need
values Omarchy's templates don't expose. Those files hold hex values, so after
editing colors.toml run:

    python3 ~/.config/omarchy/themes/moonfly/sync-overrides.py

It moves the overrides aside, lets Omarchy regenerate every file from
colors.toml, re-applies the Moonfly changes below to fresh copies, and applies
the theme again. Neovim needs nothing: it keeps its own palette in neovim.lua.
"""

import json
import os
import re
import shutil
import subprocess
import tempfile

THEME = os.path.dirname(os.path.abspath(__file__))
STATE = os.path.expanduser("~/.local/state/omarchy/current/theme")
OVERRIDES = ["shell.toml", "t3code.json", "hyprland.lua",
             "ghostty.conf", "alacritty.toml", "kitty.conf", "foot.ini"]

# Stock moonfly terminal values Omarchy's templates map differently
CURSOR = "#8E8E8E"   # moonfly cursor
BLACK = "#323437"    # moonfly grey0 (ANSI 0; the template uses the background)
WHITE = "#C6C6C6"    # moonfly white (ANSI 7; the template uses the foreground)


def read_colors():
    colors = {}
    with open(os.path.join(THEME, "colors.toml")) as f:
        for line in f:
            m = re.match(r'\s*(\w+)\s*=\s*"(#[0-9A-Fa-f]{6})"', line)
            if m:
                colors[m.group(1)] = m.group(2)
    return colors


def lighten(hex_color, amount):
    """Mix a colour toward white by amount (0..1)."""
    rgb = [int(hex_color[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(v + (255 - v) * amount):02X}" for v in rgb)


def theme_set():
    subprocess.run(["omarchy", "theme", "set", "Moonfly"], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def read(name):
    with open(os.path.join(STATE, name)) as f:
        return f.read()


def write(name, text):
    with open(os.path.join(THEME, name), "w") as f:
        f.write(text)


def sub(pattern, repl, text):
    new, n = re.subn(pattern, repl, text, flags=re.M)
    if n == 0:
        raise SystemExit(f"pattern not found (template changed?): {pattern}")
    return new


def terminals(c):
    t = read("ghostty.conf")
    t = sub(r"^cursor-color = .*$", f"cursor-color = {CURSOR}", t)
    t = sub(r"^palette = 0=.*$", f"palette = 0={BLACK}", t)
    t = sub(r"^palette = 7=.*$", f"palette = 7={WHITE}", t)
    write("ghostty.conf", t)

    t = read("alacritty.toml")
    t = sub(r'^cursor = ".*"$', f'cursor = "{CURSOR}"', t)
    t = sub(r'(\[colors\.normal\]\nblack = )".*"', rf'\1"{BLACK}"', t)
    t = sub(r'(\[colors\.normal\](?:\n.*){7}\nwhite = )".*"', rf'\1"{WHITE}"', t)
    write("alacritty.toml", t)

    t = read("kitty.conf")
    t = sub(r"^cursor #\w+$", f"cursor {CURSOR}", t)
    t = sub(r"^color0 .*$", f"color0 {BLACK}", t)
    t = sub(r"^color7 .*$", f"color7 {WHITE}", t)
    # Tabs and borders on the hairline grey instead of the accent
    t = sub(r"^active_border_color .*$", f"active_border_color {c['surface_border']}", t)
    write("kitty.conf", t)

    t = read("foot.ini")
    t = sub(r"^cursor=(\w+) \w+$", rf"cursor=\1 {CURSOR[1:]}", t)
    t = sub(r"^regular0=.*$", f"regular0={BLACK[1:]}", t)
    t = sub(r"^regular7=.*$", f"regular7={WHITE[1:]}", t)
    write("foot.ini", t)


def t3code(c):
    d = json.loads(read("t3code.json"))
    d["colors"].update({
        # One accent: blue send button with dark text, theme red stop button
        "messageAction": c["accent"],
        "messageActionForeground": c["background"],
        "messageActionHover": lighten(c["accent"], 0.2),
        "error": c["red"],
        # Surfaces: canvas < sidebar < floating < overlay, hairline borders
        "surface": c["float_background"],
        "surfaceRaised": c["float_background"],
        "surfaceOverlay": c["overlay_background"],
        "input": c["float_background"],
        "border": c["surface_border"],
        "toolbarBorder": c["surface_border"],
        "sidebarBorder": c["surface_border"],
        # Neutral active row instead of an accent tint
        "sidebarRowActive": c["lighter_background"],
    })
    write("t3code.json", json.dumps(d, indent=2) + "\n")


def shell(c):
    accent, float_bg, hairline = c["accent"], c["float_background"], c["surface_border"]
    edits = {
        # Quiet controls: faint idle outline, neutral hover, accent selection
        ("controls", "normal-border-alpha"): 0.12,
        ("controls", "normal-fill-alpha"): 0.03,
        ("controls", "selected-color"): accent,
        ("controls", "selected-fill-alpha"): 0.16,
        # Floating surfaces: opaque, so live content never shows through a
        # panel, with a 1px hairline edge
        ("popups", "background"): float_bg,
        ("popups", "background-alpha"): 1.0,
        ("popups", "border"): hairline,
        ("popups", "border-width"): 1,
        ("tooltip", "background"): float_bg,
        ("tooltip", "border"): hairline,
        ("notifications", "background"): float_bg,
        ("notifications", "background-alpha"): 1.0,
        ("notifications", "border"): hairline,
        ("notifications", "border-width"): 1,
        # Spotlight-style launcher and menus: a solid accent row, dark text
        ("launcher", "background"): float_bg,
        ("launcher", "background-alpha"): 1.0,
        ("launcher", "border"): hairline,
        ("launcher", "scrim-alpha"): 0.3,
        ("launcher", "selected-background"): accent,
        ("launcher", "selected-background-alpha"): 0.9,
        ("launcher", "selected-text"): c["background"],
        ("launcher", "selected-border-alpha"): 0.0,
        ("menu", "background"): float_bg,
        ("menu", "background-alpha"): 1.0,
        ("menu", "border"): hairline,
        ("menu", "scrim-alpha"): 0.3,
        ("menu", "selected-background"): accent,
        ("menu", "selected-background-alpha"): 0.9,
        ("menu", "selected-text"): c["background"],
        ("menu", "selected-border-alpha"): 0.0,
        ("polkit", "background"): float_bg,
        ("polkit", "border"): hairline,
        ("polkit", "scrim-alpha"): 0.3,
        ("lock", "background"): float_bg,
        ("lock", "border"): hairline,
        ("lock", "border-active"): accent,
    }
    lines = read("shell.toml").split("\n")
    section, done = None, set()
    for i, line in enumerate(lines):
        m = re.match(r"^\[([\w-]+)\]\s*$", line)
        if m:
            section = m.group(1)
            continue
        # Also takes commented-out keys (e.g. `# border-width = 2`)
        m = re.match(r"^(?:#\s*)?([\w-]+)(\s*=\s*)(.*)$", line)
        key = (section, m.group(1)) if m else None
        if key in edits and key not in done:
            value = edits[key]
            text = str(value) if isinstance(value, (int, float)) else f'"{value}"'
            lines[i] = m.group(1) + m.group(2) + text
            done.add(key)
    missing = set(edits) - done
    if missing:
        raise SystemExit(f"shell.toml keys not found (template changed?): {sorted(missing)}")
    # Extra keys only the cloned lock screen (saiddis.lock) reads: the clock,
    # and the statusline's mode pill in moonfly's statusline mode colours.
    lock_extra = [
        "# Extra keys for a moonfly-style lock screen plugin (saiddis.lock): clock,",
        "# statusline and its mode pill. Omarchy's own lock screen ignores them.",
        f'clock            = "{c["bright_foreground"]}"',
        f'date             = "{c["muted"]}"',
        f'statusline       = "{float_bg}"',
        f'mode-text        = "{c["background"]}"',
        f'mode-normal      = "{accent}"',
        f'mode-insert      = "{c["bright_green"]}"',
        f'mode-command     = "{c["yellow"]}"',
        f'mode-error       = "{c["red"]}"',
    ]
    start = lines.index("[lock]")
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("[")), len(lines))
    while end > start and not lines[end - 1].strip():
        end -= 1
    lines[end:end] = lock_extra
    header = (
        "# Moonfly shell, generated from colors.toml (sync-overrides.py, in the\n"
        "# author's copy of the theme). Replaces the shell.toml Omarchy would\n"
        "# generate: neutral controls with an accent selection, opaque popups with\n"
        "# hairline borders, and Spotlight-style selected rows."
    )
    text = "\n".join(lines)
    text = re.sub(r"\A(# [^\n]*\n)+", header + "\n", text, count=1)
    write("shell.toml", text)


def hyprland(c):
    fg, muted, accent = c["foreground"], c["muted"], c["accent"][1:]
    look = f'''
-- Moonfly look, added by sync-overrides.py: flat rounded windows, a soft
-- shadow, and a 2px border that is moonfly blue on the focused window and a
-- hairline grey elsewhere. Group tabs use the same font and accent.
hl.config({{
  general = {{
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
  }},

  decoration = {{
    rounding = 10,
    rounding_power = 3,

    shadow = {{
      enabled = true,
      range = 20,
      render_power = 3,
      offset = "0 4",
      color = "rgba(00000099)",
      color_inactive = "rgba(00000055)",
    }},
  }},

  group = {{
    groupbar = {{
      font_family = "JetBrainsMono Nerd Font",
      font_size = 11,
      font_weight_active = "bold",
      font_weight_inactive = "normal",
      height = 20,
      indicator_height = 2,
      gradients = false,
      text_color = "rgb({fg[1:]})",
      text_color_inactive = "rgb({muted[1:]})",
      col = {{
        active = "rgb({accent})",
        inactive = "rgb({c["surface_border"][1:]})",
      }},
    }},
  }},
}})
'''
    write("hyprland.lua", read("hyprland.lua").rstrip("\n") + "\n" + look)


def main():
    c = read_colors()
    with tempfile.TemporaryDirectory() as backup:
        for name in OVERRIDES:
            path = os.path.join(THEME, name)
            if os.path.exists(path):
                shutil.move(path, os.path.join(backup, name))
        try:
            theme_set()  # Omarchy regenerates everything from colors.toml
            terminals(c)
            t3code(c)
            shell(c)
            hyprland(c)
        except BaseException:
            for name in OVERRIDES:  # put the old overrides back on failure
                if os.path.exists(os.path.join(backup, name)) and not os.path.exists(os.path.join(THEME, name)):
                    shutil.move(os.path.join(backup, name), os.path.join(THEME, name))
            raise
    theme_set()
    print("Moonfly overrides rebuilt from colors.toml and applied.")


if __name__ == "__main__":
    main()
