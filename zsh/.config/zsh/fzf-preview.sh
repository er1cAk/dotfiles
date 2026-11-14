#!/bin/sh
# fzf preview for any path: a tree for directories, syntax-highlighted text, and
# Unicode block art for images and for anything Quick Look can thumbnail (PDF,
# video, office documents). Alacritty implements no terminal graphics protocol,
# so block art is the best that renders inline; Ctrl-O in the picker opens the
# real file in Quick Look.
set -u

p="$1"
w="${FZF_PREVIEW_COLUMNS:-80}"
h="${FZF_PREVIEW_LINES:-40}"
[ -e "$p" ] || exit 0

if [ -d "$p" ]; then
  exec eza --tree --level=2 --icons=always --color=always --git-ignore "$p"
fi

# Joined into one line: universal binaries get one line per architecture, and
# only the last of those carries the charset.
mime="$(file --brief --mime "$p" | tr '\n' ' ')"   # e.g. "text/x-shellscript; charset=us-ascii"

case "$mime" in
  image/*) exec chafa --format=symbols --animate=off --size="${w}x$((h - 1))" "$p" ;;
  *charset=binary*) ;;
  *) exec bat --color=always --style=numbers --line-range=":$h" "$p" ;;
esac

# Quick Look thumbnails only for types it renders: its generator never returns on
# some files (Mach-O binaries), so others skip it and a watchdog caps the rest.
case "$mime" in
  application/pdf* | video/* | audio/* | application/epub* | application/msword* | \
  application/vnd.ms-* | application/vnd.openxmlformats-* | application/vnd.oasis.*)
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    qlmanage -t -s 600 -o "$tmp" "$p" >/dev/null 2>&1 &
    ql=$!
    (sleep 3; kill "$ql" 2>/dev/null) >/dev/null 2>&1 &
    watchdog=$!
    wait "$ql" 2>/dev/null
    kill "$watchdog" 2>/dev/null
    thumb="$tmp/$(basename "$p").png"
    [ -s "$thumb" ] && chafa --format=symbols --animate=off --size="${w}x$((h - 2))" "$thumb"
    ;;
esac
printf '%s, %s  (Ctrl-O: Quick Look)\n' "$(file --brief "$p" | head -1 | cut -c1-60)" "$(du -h "$p" | cut -f1 | tr -d ' ')"
