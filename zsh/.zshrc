#If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"

ZSH_THEME="jonathan"

DEFAULT_USER=$USER

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  osx
  ruby
  zsh-syntax-highlighting
)

# Guarded so a machine without oh-my-zsh gets a working shell, not an error per prompt.
if [ -d "$ZSH" ]; then
  source $ZSH/oh-my-zsh.sh
  source $ZSH/plugins/git/git.plugin.zsh
fi

# Completion. oh-my-zsh runs compinit itself; otherwise run it here with its
# security audit (the slow part) at most once a day, reusing the dump in between.
# Must come before anything that calls compdef (zoxide, ng).
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  _zcompdump_stale=( "${ZDOTDIR:-$HOME}"/.zcompdump(N.mh+24) )
  if (( $#_zcompdump_stale )) || [[ ! -s "${ZDOTDIR:-$HOME}/.zcompdump" ]]; then
    compinit
  else
    compinit -C
  fi
  unset _zcompdump_stale
fi

# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
 alias ohmyzsh="vim ~/.oh-my-zsh"
 alias letItSnow="sh ~/bin/letItSnow.sh"
 alias crontab="env EDITOR=vim crontab -e"
 notarizeHistory(){xcrun altool --notarization-history 0 -u "$1" -p} 
 alias flush.cache="dscacheutil -flushcache"

# Android SDK ROOT
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
# avdmanager, sdkmanager
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
# adb, logcat
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
# emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_HOME
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

# nvm without its startup cost. --no-use skips resolving the default version
# (~650ms per shell, felt on every new tmux pane); its bin goes on PATH directly
# instead. Aliases are followed through nvm's alias files (default -> 22, or
# lts/* -> lts/jod -> v22.x) and the highest installed match wins; anything that
# does not resolve that way (node, stable) falls back to a real `nvm use`.
# nvm's bash_completion is deliberately not sourced: it runs an uncached compinit.
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  \. "/opt/homebrew/opt/nvm/nvm.sh" --no-use
  _nvm_v=""
  [[ -f "$NVM_DIR/alias/default" ]] && _nvm_v="$(<"$NVM_DIR/alias/default")"
  for _i in 1 2 3 4; do
    [[ -n "$_nvm_v" && -f "$NVM_DIR/alias/$_nvm_v" ]] && _nvm_v="$(<"$NVM_DIR/alias/$_nvm_v")"
  done
  _nvm_dir=( "$NVM_DIR"/versions/node/v${_nvm_v#v}(|.*)(N/nOn) )
  if [[ -n "$_nvm_v" && -n "$_nvm_dir" ]]; then
    export NVM_BIN="${_nvm_dir[1]}/bin" NVM_INC="${_nvm_dir[1]}/include/node"
    # tmux panes inherit a PATH that already holds a node bin; drop it, as `nvm use` would
    path=( "$NVM_BIN" ${path:#$NVM_DIR/versions/node/*/bin} )
  else
    nvm use default --silent >/dev/null 2>&1
  fi
  unset _nvm_v _nvm_dir _i
fi

command -v starship >/dev/null && eval "$(starship init zsh)"

# Load Angular CLI autocompletion.
command -v ng >/dev/null && source <(ng completion script)

export GPG_TTY=$(tty)

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# nv -- open nvim with the project's DB credentials injected as env vars.
#
# vim-dadbod-ui reads any DB_UI_* environment variable as a connection (the name
# is whatever follows the prefix, lowercased), so nothing has to be stored on
# disk. Store DB_UI_DEV, DB_UI_STAGING, ... in Infisical or a gitignored .env and
# they show up under <leader>D.
nv() {
  if [ -f .infisical.json ]; then
    infisical run --silent -- nvim "$@"
  elif [ -f .env ]; then
    ( set -a; . ./.env; set +a; nvim "$@" )
  else
    nvim "$@"
  fi
}

# History, shared live across every tmux pane and window: a command run in one
# pane is reachable with Up or Ctrl-R in all the others.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history          # implies incremental append, with timestamps
setopt hist_ignore_all_dups   # re-running a command moves it up instead of duplicating it
setopt hist_ignore_space      # a leading space keeps a command (and any token in it) out of history
setopt hist_reduce_blanks

# fzf: Ctrl-R fuzzy history, Ctrl-T inserts a file path, Alt-C cds into a subdirectory.
if command -v fzf >/dev/null; then
  # fd respects .gitignore, so node_modules and build output stay out of the lists
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
  # Catppuccin Mocha, query line on top
  export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a"
  source <(fzf --zsh)
fi

# zoxide: `z lois` jumps to the most-used directory matching "lois"; `zi` picks with fzf.
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# Suggestions from history (accept with Right arrow) and command highlighting.
# Skipped where oh-my-zsh already loaded them as plugins. Highlighting wraps every
# widget defined before it, so it must stay after fzf and autosuggestions.
BREW_SHARE="${HOMEBREW_PREFIX:-/opt/homebrew}/share"
if (( ! $+functions[_zsh_autosuggest_start] )) && [ -f "$BREW_SHARE/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"   # Catppuccin overlay0: visible, clearly not typed
  source "$BREW_SHARE/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if (( ! ${+ZSH_HIGHLIGHT_VERSION} )) && [ -f "$BREW_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$BREW_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset BREW_SHARE

# Machine-specific PATHs, credentials and tool installs live in this untracked
# file, sourced last so it can override anything above. Never move them here:
# this repo is public.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
