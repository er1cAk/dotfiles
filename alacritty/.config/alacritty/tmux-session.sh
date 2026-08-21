#!/bin/sh
# Pick a tmux session for a new Alacritty window.
#
# Every window used to run `tmux new-session -A -s main`, so window two attached
# to the SAME session: a mirror of window one that also resized it (tmux uses
# window-size latest). Instead: reuse "main" when no client is attached to it, so
# closing and reopening a lone window resumes your work; otherwise take the next
# free name and get an independent workspace.
set -eu

name=main
i=2
while tmux has-session -t "$name" 2>/dev/null \
   && [ -n "$(tmux list-clients -t "$name" 2>/dev/null)" ]; do
  name="main-$i"
  i=$((i + 1))
done

exec tmux new-session -A -s "$name"
