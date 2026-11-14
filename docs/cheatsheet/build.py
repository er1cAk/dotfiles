"""Render spec.txt into the print-styled HTML that build.sh turns into a PDF.

Spec syntax: `=== PAGE[ | heading | subtitle]` starts a page, `## Title | colour |
subtitle` a section (subtitle `-` for none), `### text` a sub-heading, `> text` a
note, `keys | description` a row (split on the last " | "). `{x}` becomes a key
chip; the small inline-HTML vocabulary (b, i, code, span) passes through and
everything else is escaped.
"""
import datetime
import html
import re
import sys

spec_path, out_path = sys.argv[1], sys.argv[2]

LATTE = {
    "blue": "#1e66f5", "green": "#40a02b", "mauve": "#8839ef", "peach": "#fe640b",
    "teal": "#179299", "yellow": "#df8e1d", "red": "#d20f39", "sapphire": "#209fb5",
}

PROMPT = (
    '<div class="term">'
    '<span style="color:#89b4fa;font-weight:700">lois-frontend</span> on '
    '<span style="color:#cba6f7;font-weight:700"> main</span> '
    '<span style="color:#fab387">?⇣3</span> via '
    '<span style="color:#a6e3a1"> v22.23.2</span> took '
    '<span style="color:#f9e2af">4s</span><br>'
    '<span style="color:#a6e3a1;font-weight:700">❯</span> '
    '<span style="color:#6c7086">git pull</span></div>'
    '<div class="termcap">directory · branch · git status · runtime · slow command, '
    'then the input line</div>'
)

KEEP = r"</?(?:b|i|code|span[^>]*)>|&[a-z]+;"


def chip(m):
    k = m.group(1)  # already escaped by inline()
    if k.startswith("␣") and len(k) > 1:
        k = '<span class="ld">␣</span>' + k[1:]
    return f"<kbd>{k}</kbd>"


def inline(text):
    parts = re.split(f"({KEEP})", text)
    out = "".join(p if re.fullmatch(KEEP, p or "") else html.escape(p, quote=False) for p in parts)
    return re.sub(r"\{([^}]*)\}", chip, out)


pages, sec = [], None
for raw in open(spec_path, encoding="utf-8"):
    line = raw.rstrip("\n")
    if not line.strip():
        continue
    if line.startswith("=== PAGE"):
        head = [s.strip() for s in line.split(" | ")[1:]]
        pages.append({"head": head, "secs": []})
    elif line.startswith("## "):
        title, colour, sub = (s.strip() for s in line[3:].split(" | ", 2))
        sec = {"title": title, "colour": LATTE[colour], "sub": sub, "body": []}
        pages[-1]["secs"].append(sec)
    elif line.startswith("### "):
        sec["body"].append(f'<tr class="sub"><td colspan="2">{inline(line[4:])}</td></tr>')
    elif line.startswith("> "):
        sec["body"].append(f'<tr class="note"><td colspan="2">{inline(line[2:])}</td></tr>')
    elif line == "@@PROMPT@@":
        sec["body"].append(f'<tr class="prompt"><td colspan="2">{PROMPT}</td></tr>')
    else:
        keys, desc = line.rsplit(" | ", 1)
        sec["body"].append(f'<tr><td class="k">{inline(keys)}</td><td>{inline(desc)}</td></tr>')

CSS = """
@page { size: A4 landscape; margin: 8mm 9mm; }
* { box-sizing: border-box; }
html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body { margin: 0; font: 7.7pt/1.34 -apple-system, "SF Pro Text", "Helvetica Neue", sans-serif;
       color: #4c4f69; background: #fff; }
.page { height: 193mm; display: flex; flex-direction: column; break-after: page; overflow: hidden; }
.page:last-child { break-after: auto; }
header { display: flex; align-items: baseline; gap: 14px; padding-bottom: 4px;
         border-bottom: 1.5px solid #dce0e8; margin-bottom: 7px; flex: none; }
header h1 { font-size: 15pt; margin: 0; color: #1e1e2e; letter-spacing: -0.2px; }
header .legend { color: #6c6f85; }
header .date { margin-left: auto; color: #9ca0b0; }
.group { flex: 1; min-height: 0; column-count: 3; column-gap: 7mm; column-fill: balance; }
section { break-inside: avoid; margin: 0 0 8px; border-left: 3px solid var(--c); padding-left: 6px; }
section h2 { margin: 0; font-size: 10pt; color: var(--c); }
section .subt { color: #6c6f85; margin: 0 0 2px; }
table { border-collapse: collapse; width: 100%; }
td { padding: 1.15px 0; vertical-align: top; }
td.k { white-space: nowrap; padding-right: 7px; width: 1%; }
tr.sub td { padding-top: 4px; font-weight: 650; color: #5c5f77; font-size: 7.3pt;
            text-transform: uppercase; letter-spacing: 0.4px; }
tr.sub kbd { text-transform: none; }
tr.note td { color: #6c6f85; font-style: italic; padding-top: 2px; }
kbd { font: 600 7.3pt/1 "JetBrainsMono Nerd Font Mono", ui-monospace, monospace;
      background: #eff1f5; border: 1px solid #ccd0da; border-bottom-width: 1.5px;
      border-radius: 3px; padding: 1px 3px; color: #1e1e2e; white-space: nowrap; }
kbd .ld { color: #8839ef; font-weight: 800; font-size: 1.15em; margin-right: 1px; }
code { font: 7.2pt "JetBrainsMono Nerd Font Mono", ui-monospace, monospace; color: #1e1e2e;
       background: #f2f3f6; padding: 0 2px; border-radius: 2px; }
.ghost { color: #8c8fa1; font-family: "JetBrainsMono Nerd Font Mono", monospace; }
.ok { color: #40a02b; font-weight: 700; } .bad { color: #d20f39; font-weight: 700; }
.term { background: #1e1e2e; color: #cdd6f4; border-radius: 5px; padding: 5px 7px;
        font: 7.4pt/1.45 "JetBrainsMono Nerd Font Mono", monospace; margin: 2px 0 1px; }
.termcap { color: #6c6f85; font-size: 6.8pt; margin-bottom: 2px; }
footer { color: #9ca0b0; font-size: 6.6pt; margin-top: 6px; break-inside: avoid; }"""

LEGEND = ('<div class="legend"><kbd>⌘</kbd> Cmd &nbsp; <kbd>⌥</kbd> Option (Alt) &nbsp; '
          '<kbd>⌃</kbd> Ctrl &nbsp; <kbd>⇧</kbd> Shift &nbsp; <kbd>↩</kbd> Return &nbsp; '
          '<kbd>␣</kbd> Space</div>')

FOOTER = """<footer>Built from the live config, not from memory: Neovim keys from nvim_get_keymap,
tmux from list-keys, Alacritty from alacritty.toml, zsh from bindkey, lazygit from its v0.66.3
keybinding docs. If a key here stops working, the config changed: fix docs/cheatsheet/spec.txt
and run docs/cheatsheet/build.sh.</footer>"""

# Flags any page whose columns spill past the right edge, which in print would
# silently clip content.
CHECK = """<script>
addEventListener('load', () => {
  const bad = [];
  document.querySelectorAll('.group').forEach((g, i) => {
    const r = g.getBoundingClientRect();
    g.querySelectorAll('section, footer').forEach(s => {
      const b = s.getBoundingClientRect();
      if (b.right > r.right + 1 || b.bottom > r.bottom + 1)
        bad.push('page ' + (i + 1) + ': ' + (s.querySelector('h2')?.textContent || 'footer'));
    });
  });
  document.body.dataset.overflow = bad.length ? bad.join('; ') : 'none';
});
</script>"""

out = []
for i, page in enumerate(pages):
    if i == 0:
        head = f'<header><h1>Terminal cheatsheet</h1>{LEGEND}<div class="date">~/dotfiles · {datetime.date.today():%d %b %Y}</div></header>'
    else:
        title, sub = page["head"]
        head = f'<header><h1>{inline(title)}</h1><div class="legend">{inline(sub)}</div></header>'
    secs = "".join(
        f'<section style="--c:{s["colour"]}"><h2>{inline(s["title"])}</h2>'
        + (f'<div class="subt">{inline(s["sub"])}</div>' if s["sub"] != "-" else "") + f'<table>{"".join(s["body"])}</table></section>'
        for s in page["secs"]
    )
    if i == len(pages) - 1:
        secs += FOOTER
    out.append(f'<div class="page">{head}<div class="group">{secs}</div></div>')

doc = f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<title>Terminal cheatsheet</title><style>{CSS}</style></head>
<body>{"".join(out)}{CHECK}</body></html>"""
open(out_path, "w", encoding="utf-8").write(doc)
print(f"{len(pages)} pages, {sum(len(p['secs']) for p in pages)} sections -> {out_path}")
