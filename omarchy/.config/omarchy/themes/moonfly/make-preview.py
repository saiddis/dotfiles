#!/usr/bin/env python3
"""Render preview.png for a Moonfly-family Omarchy theme from its colors.toml.

The theme switcher only lists themes that have a preview image (or a
wallpaper). Run after changing a theme's colours:

    python3 ~/.config/omarchy/themes/moonfly/make-preview.py ~/.config/omarchy/themes/<theme>

Draws a mock desktop (bar, Neovim, terminal) at 2560x1440 with headless Chromium.
"""

import html
import os
import re
import subprocess
import sys
import tempfile


def read_colors(theme_dir):
    colors = {}
    with open(os.path.join(theme_dir, "colors.toml")) as f:
        for line in f:
            m = re.match(r'\s*(\w+)\s*=\s*"(#[0-9A-Fa-f]{6})"', line)
            if m:
                colors[m.group(1)] = m.group(2)
    return colors


def roles(t):
    # Same role resolution as neovim.lua
    g = lambda key, fallback: t.get("syntax_" + key, t[fallback])
    return {
        "keyword": g("keyword", "magenta"),
        "operator": g("operator", "orange"),
        "warning": g("warning", "orange"),
        "function": g("function", "cyan"),
        "type": g("type", "green"),
        "string": g("string", "yellow"),
        "number": g("number", "bright_blue"),
        "parameter": g("parameter", "bright_magenta"),
        "property": g("property", "blue"),
        "module": g("module", "bright_green"),
        "fg": t["foreground"],
        "comment": t["muted"],
        "error": t["red"],
    }


def build(theme_dir):
    t = read_colors(theme_dir)
    r = roles(t)
    name = os.path.basename(os.path.normpath(theme_dir)).replace("-", " ").title()

    def s(role, text, style=""):
        return f'<span style="color:{r[role]};{style}">{html.escape(text)}</span>'

    code = [
        s("operator", "from") + " " + s("module", "collections.abc") + " " + s("operator", "import") + " " + s("type", "AsyncGenerator"),
        s("operator", "from") + " " + s("module", "contextlib") + " " + s("operator", "import") + " " + s("fg", "asynccontextmanager"),
        "",
        s("operator", "import") + " " + s("module", "uvicorn"),
        s("operator", "from") + " " + s("module", "fastapi") + " " + s("operator", "import") + " " + s("type", "Depends") + s("fg", ", ") + s("type", "FastAPI"),
        "",
        s("operator", "from") + " " + s("module", "app.config") + " " + s("operator", "import") + " " + s("type", "Config") + s("fg", ", get_config"),
        s("operator", "from") + " " + s("module", "app.llm") + " " + s("operator", "import") + " " + s("type", "ManagedLLMClient"),
        "",
        "",
        s("keyword", "def") + " " + s("function", "create_llm") + s("fg", "(") + s("parameter", "config") + s("fg", ": ") + s("type", "Config") + s("fg", ") ") + s("operator", "->") + " " + s("type", "ManagedLLMClient") + s("fg", ":"),
        "    " + s("comment", '"""Create the configured model backend."""'),
        "    " + s("keyword", "return") + " " + s("function", "create_llm_client") + s("fg", "(config, ") + s("parameter", "retries") + s("operator", "=") + s("number", "3") + s("fg", ")"),
        "",
        "",
        s("function", "@asynccontextmanager"),
        s("keyword", "async def") + " " + s("function", "lifespan") + s("fg", "(") + s("parameter", "app") + s("fg", ": ") + s("type", "FastAPI") + s("fg", ") ") + s("operator", "->") + " " + s("type", "AsyncGenerator") + s("fg", "[") + s("number", "None") + s("fg", ", ") + s("number", "None") + s("fg", "]:"),
        "    " + s("comment", '"""Initialize and close process-wide resources."""'),
        "    " + s("fg", "config ") + s("operator", "=") + " " + s("function", "get_config") + s("fg", "()"),
        "    " + s("fg", "llm ") + s("operator", "=") + " " + s("function", "create_llm") + s("fg", "(config)"),
        "    " + s("keyword", "if") + " " + s("fg", "config.") + s("property", "eager_load") + s("fg", ":"),
        "        " + s("fg", "llm.") + s("function", "load") + s("fg", "()"),
        "",
        "    " + s("fg", "app.") + s("property", "state") + s("fg", ".") + s("property", "config") + " " + s("operator", "=") + s("fg", " config"),
        "    " + s("fg", "app.") + s("property", "state") + s("fg", ".") + s("property", "mode") + " " + s("operator", "=") + " " + s("string", '"single-flight"') + "  " + s("comment", "# deprecated path", "font-style:italic"),
        "    " + s("keyword", "yield"),
        "    " + s("keyword", "await") + " " + s("fg", "llm.") + s("function", "close") + s("fg", "()"),
    ]
    rows = []
    for i, line in enumerate(code, 1):
        bg = ""
        if i == 19:
            bg = f"background:{t['lighter_background']};"
        if i == 22:
            bg = f"background:{t['selection']};"
        nr = t["accent"] if i == 19 else t["dark_foreground"]
        sign = ""
        diag = ""
        if i == 20:
            sign = f'<span style="color:{r["error"]}">●</span>'
            diag = f'   <span style="color:{r["error"]};font-style:italic">■ Argument of type "Config | None" cannot be assigned</span>'
        if i == 25:
            sign = f'<span style="color:{r["warning"]}">▲</span>'
        rows.append(
            f'<div class="ln" style="{bg}"><span class="sg">{sign}</span>'
            f'<span class="nr" style="color:{nr}">{i}</span><span>{line or "&nbsp;"}{diag}</span></div>'
        )

    ansi = ["red", "green", "yellow", "blue", "magenta", "cyan"]
    swatches = "".join(
        f'<div class="sw" style="background:{t[c]}"></div>' for c in ansi
    ) + "".join(f'<div class="sw" style="background:{t["bright_" + c]}"></div>' for c in ansi)

    term = [
        f'<span style="color:{t["accent"]}">~/Projects/test-practice</span> <span style="color:{t["green"]}">main</span> <span style="color:{t["magenta"]}">❯</span> ls',
        f'<span style="color:{t["blue"]};font-weight:700">apps</span>  <span style="color:{t["blue"]};font-weight:700">contracts</span>  <span style="color:{t["blue"]};font-weight:700">docs</span>  <span style="color:{t["blue"]};font-weight:700">infra</span>  <span style="color:{t["blue"]};font-weight:700">services</span>  Makefile  README.md  go.work',
        f'<span style="color:{t["accent"]}">~/Projects/test-practice</span> <span style="color:{t["green"]}">main</span> <span style="color:{t["magenta"]}">❯</span> git status -s',
        f'<span style="color:{t["green"]}">A</span>  services/generators/toefl/app/main.py',
        f'<span style="color:{t["red"]}"> M</span> apps/test-practice-web/src/app.d.ts',
        f'<span style="color:{t["red"]}">??</span> notes.md',
        f'<span style="color:{t["accent"]}">~/Projects/test-practice</span> <span style="color:{t["green"]}">main</span> <span style="color:{t["magenta"]}">❯</span> <span style="background:{t["foreground"]}">&nbsp;</span>',
    ]

    return f"""<!doctype html><html><head><meta charset="utf-8"><style>
* {{ box-sizing: border-box; margin: 0; }}
body {{ width: 2560px; height: 1440px; background: {t['background']}; color: {t['foreground']};
  font-family: 'JetBrainsMono Nerd Font', 'JetBrains Mono', monospace; font-size: 24px; line-height: 1.6; overflow: hidden; }}
.bar {{ height: 52px; display: flex; align-items: center; padding: 0 28px; gap: 26px; color: {t['foreground']}; }}
.bar .ws {{ color: {t['dark_foreground']}; }} .bar .on {{ color: {t['accent']}; font-weight: 700; }}
.bar .mid {{ margin: 0 auto; }}
.grid {{ position: absolute; top: 60px; left: 16px; right: 16px; bottom: 16px; display: grid;
  grid-template-columns: 1.55fr 1fr; grid-template-rows: 1fr 1fr; gap: 16px; }}
.win {{ border: 3px solid {t['dark_foreground']}; padding: 10px 14px; overflow: hidden; position: relative; }}
.win.active {{ border-color: {t['accent']}; grid-row: span 2; display: flex; flex-direction: column; }}
.tabs {{ display: flex; gap: 6px; margin-bottom: 4px; }}
.tab {{ padding: 0 22px; color: {t['muted']}; }}
.tab.sel {{ color: {t['foreground']}; border-left: 4px solid {t['accent']}; font-style: italic; }}
.code {{ flex: 1; }}
.ln {{ display: flex; white-space: pre; }}
.sg {{ width: 30px; text-align: center; }}
.nr {{ width: 44px; text-align: right; padding-right: 26px; }}
.status {{ display: flex; align-items: center; gap: 22px; }}
.mode {{ background: {t['accent']}; color: {t['background']}; font-weight: 700; padding: 0 16px; }}
.term div {{ white-space: pre; }}
.swatches {{ display: grid; grid-template-columns: repeat(6, 1fr); gap: 10px; margin-top: 22px; }}
.sw {{ height: 46px; }}
.card {{ position: absolute; right: 26px; bottom: 26px; background: {t['dark_background']}; padding: 22px 28px; }}
.card b {{ color: {t['accent']}; font-size: 34px; }}
.card div {{ color: {t['muted']}; }}
</style></head><body>
<div class="bar"><span class="on">1</span><span class="ws">2</span><span class="ws">3</span><span class="ws">4</span><span class="ws">5</span>
<span class="mid">Sunday 10:45</span><span style="color:{t['muted']}">{html.escape(name)}</span></div>
<div class="grid">
  <div class="win active">
    <div class="tabs"><span class="tab sel">main.py</span><span class="tab">dependencies.py</span><span class="tab">main.go</span><span class="tab">config.ts</span></div>
    <div class="code">{''.join(rows)}</div>
    <div class="status"><span class="mode">NORMAL</span><span style="color:{t['accent']}"> main</span>
      <span style="color:{t['muted']}">services/…/app/main.py</span><span style="margin-left:auto;color:{t['accent']}">19:5</span></div>
  </div>
  <div class="win term">{''.join(f'<div>{l}</div>' for l in term)}<div class="swatches">{swatches}</div></div>
  <div class="win"><div class="card"><b>{html.escape(name)}</b><div>background {t['background']} · accent {t['accent']}</div></div>
    <div style="color:{t['muted']}">{''.join(f'<div><span style="color:{t[k]}">■</span> {k.replace("_", " ")}</div>' for k in ["accent", "foreground", "muted", "selection", "lighter_background", "dark_background"])}</div></div>
</div></body></html>"""


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    theme_dir = os.path.expanduser(sys.argv[1])
    out = os.path.join(theme_dir, "preview.png")
    with tempfile.TemporaryDirectory() as tmp:
        page = os.path.join(tmp, "preview.html")
        with open(page, "w") as f:
            f.write(build(theme_dir))
        subprocess.run(
            ["chromium", "--headless", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
             f"--user-data-dir={tmp}/profile", "--window-size=2560,1440", f"--screenshot={out}", "file://" + page],
            check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    print(out)


if __name__ == "__main__":
    main()
