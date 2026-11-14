#!/usr/bin/env bash
#
# Rebuild docs/cheatsheet.pdf from spec.txt. Needs python3 and a Chromium-family
# browser for headless print-to-PDF; nothing else.
#
# spec.txt is curated by hand, but every key in it was checked against the live
# config (nvim_get_keymap, tmux list-keys, alacritty.toml, bindkey, lazygit's docs
# for the installed version). Check the keys you add or change the same way: the
# markdown cheatsheet this replaced had drifted from the config within weeks.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/../cheatsheet.pdf"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

CHROME=""
for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "/Applications/Chromium.app/Contents/MacOS/Chromium" \
         "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
  if [[ -x "$c" ]]; then CHROME="$c"; break; fi
done
[[ -n "$CHROME" ]] || { echo "no Chromium-family browser found for print-to-PDF" >&2; exit 1; }

python3 "$HERE/build.py" "$HERE/spec.txt" "$WORK/cheatsheet.html"

# Sections never split across columns, so one that does not fit is pushed past
# the page edge and silently clipped in print. build.py records any such section
# in body[data-overflow]; lay out at the printable width (A4 landscape minus the
# @page margins) and refuse to write a PDF with content missing.
OVERFLOW="$("$CHROME" --headless=new --disable-gpu --user-data-dir="$WORK/profile" \
  --window-size=1054,733 --virtual-time-budget=3000 --dump-dom "file://$WORK/cheatsheet.html" 2>/dev/null \
  | grep -oE 'data-overflow="[^"]*"' || true)"
if [[ "$OVERFLOW" != 'data-overflow="none"' ]]; then
  echo "layout overflow, PDF not written: ${OVERFLOW:-the check did not run}" >&2
  exit 1
fi

"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir="$WORK/profile" \
  --print-to-pdf="$OUT" "file://$WORK/cheatsheet.html" >/dev/null 2>&1
echo "wrote $OUT"
