#!/bin/sh
# Fuzzy-pick a git repo and switch to its own tmux session, creating it on first
# use, so each project keeps its editor, servers and shells alive between visits.
# Repos zoxide knows come first (most used on top), then the rest of ~/Work and
# ~/dotfiles. Bound to prefix f, which Cmd-O in Alacritty sends; outside tmux it
# attaches instead of switching.
#
# Runs in a tmux popup, whose environment never read .zshrc, so it points fzf at
# the shared options file itself.
set -eu

export FZF_DEFAULT_OPTS_FILE="${FZF_DEFAULT_OPTS_FILE:-$HOME/.config/zsh/fzfrc}"

candidates() {
  {
    command -v zoxide >/dev/null && zoxide query --list
    find "$HOME/Work" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
    echo "$HOME/dotfiles"
  } | awk '!seen[$0]++' | while IFS= read -r d; do
    [ -e "$d/.git" ] || continue
    case "$d" in
      "$HOME"/*) printf '~%s\t%s\n' "${d#"$HOME"}" "$d" ;;
      *) printf '%s\t%s\n' "$d" "$d" ;;
    esac
  done
}

pick="$(candidates | fzf --height=100% --prompt='project › ' --delimiter='\t' --with-nth=1 \
  --preview 'git -C {2} -c color.ui=always status -sb | head -1; echo; git -C {2} -c color.ui=always log --oneline --decorate -8; echo; eza --tree --level=1 --icons=always --color=always {2}')" || exit 0

dir="$(printf '%s' "$pick" | cut -f2)"
name="$(basename "$dir" | tr '.:' '__')"   # tmux session names cannot hold . or :

tmux has-session -t "=$name" 2>/dev/null || tmux new-session -d -s "$name" -c "$dir"
if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t "=$name"
else
  exec tmux attach-session -t "=$name"
fi
