#!/usr/bin/env bash
#
# Restore this setup on a Mac. Safe to re-run: every step is idempotent.
#
#   ./install.sh            apply
#   ./install.sh --dry-run  show what would happen, change nothing
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim alacritty tmux zsh git)
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }
run()  { if (( DRY_RUN )); then printf '  would run: %s\n' "$*"; else "$@"; fi; }

# ---------------------------------------------------------------- prereqs ---
say "Checking prerequisites"

[[ "$(uname -s)" == "Darwin" ]] || die "This bootstrap is macOS-only."
command -v git  >/dev/null || die "git not found."
command -v brew >/dev/null || die "Homebrew not found -- install it from https://brew.sh first."

# Treesitter parsers are compiled from source; without the CLT there is no compiler
# and TSInstallAll fails with a confusing error rather than a useful one.
xcode-select -p >/dev/null 2>&1 \
  || die "Xcode Command Line Tools missing. Run: xcode-select --install"

echo "  macOS, git, brew, Xcode CLT all present"

# ------------------------------------------------------------- homebrew ---
say "Installing packages from Brewfile"
run brew bundle --file="$DOTFILES/Brewfile"

# Neovim >= 0.12 is a hard requirement: NvChad ships nvim-treesitter's `main`
# branch, which calls APIs (vim.list.unique) that do not exist in 0.11.
if command -v nvim >/dev/null; then
  NVIM_VER="$(nvim --version | head -1 | sed 's/^NVIM v//')"
  if [[ "$(printf '%s\n0.12.0\n' "$NVIM_VER" | sort -V | head -1)" != "0.12.0" ]]; then
    die "Neovim $NVIM_VER is too old; >= 0.12 required. Try: brew upgrade neovim"
  fi
  echo "  neovim $NVIM_VER"
fi

# ----------------------------------------------------------------- stow ---
say "Linking dotfiles with stow"

# NEVER use --adopt: it resolves conflicts by overwriting THIS REPO with whatever
# is already on the machine, silently discarding the good version. Detect
# conflicts and stop instead.
CONFLICTS=0
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r target; do
    dest="$HOME/${target#"$pkg/"}"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      warn "conflict: $dest already exists and is not a symlink"
      CONFLICTS=1
    fi
  done < <(cd "$DOTFILES" && find "$pkg" -type f | sed "s|^|$pkg/|;s|^$pkg/$pkg/|$pkg/|")
done

if (( CONFLICTS )); then
  die "Move or delete the files listed above, then re-run. Do not use 'stow --adopt'."
fi

for pkg in "${PACKAGES[@]}"; do
  run stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
  echo "  linked $pkg"
done

# ------------------------------------------------------------- alacritty ---
say "Alacritty terminfo and CLI"

# `alacritty` terminfo is not in the system database; without it TERM=alacritty
# is unresolvable. The app bundle ships it.
if [[ -d /Applications/Alacritty.app ]]; then
  if ! infocmp alacritty >/dev/null 2>&1; then
    run mkdir -p "$HOME/.terminfo/61"
    run cp /Applications/Alacritty.app/Contents/Resources/61/* "$HOME/.terminfo/61/"
    echo "  terminfo installed"
  else
    echo "  terminfo already present"
  fi

  # the cask installs no CLI symlink
  if [[ ! -e /opt/homebrew/bin/alacritty ]]; then
    run ln -sf /Applications/Alacritty.app/Contents/MacOS/alacritty /opt/homebrew/bin/alacritty
    echo "  CLI symlinked"
  else
    echo "  CLI already on PATH"
  fi
fi

# --------------------------------------------------------------- neovim ---
say "Neovim plugins, tools and parsers (this takes ~10 minutes)"

# `restore` installs the exact commits in lazy-lock.json.
# `sync` would UPDATE everything and REWRITE the lockfile -- the opposite of
# reproducible. Do not change this to sync.
run nvim --headless "+Lazy! restore" +qa

run nvim --headless \
  "+lua vim.api.nvim_create_autocmd('User', { pattern = 'MasonToolsUpdateCompleted', callback = function() vim.defer_fn(function() vim.cmd('qa!') end, 2000) end })" \
  "+Lazy! load mason-tool-installer.nvim" \
  "+MasonToolsInstall" \
  "+lua vim.defer_fn(function() vim.cmd('qa!') end, 900000)"

run nvim --headless \
  -c "Lazy! load nvim-treesitter" \
  -c "lua require('nvim-treesitter').install(require('lazy.core.config').plugins['nvim-treesitter'].opts.ensure_installed, {summary=true}):wait(900000)" \
  -c "qa"

# ------------------------------------------------------------- projects ---
say "Seeding the recent-projects list"

# project.nvim only records projects as you open them, so the dashboard's
# "Recent Projects" button would be empty on a fresh machine.
HIST="$HOME/.local/share/nvim/project_nvim/project_history"
if [[ -d "$HOME/work" && ! -s "$HIST" ]]; then
  run mkdir -p "$(dirname "$HIST")"
  if (( ! DRY_RUN )); then
    find "$HOME/work" -maxdepth 3 -name .git -type d 2>/dev/null \
      | sed 's|/\.git$||' | sort > "$HIST"
    echo "  seeded $(wc -l < "$HIST" | tr -d ' ') projects"
  fi
else
  echo "  skipped (no ~/work, or history already exists)"
fi

# ----------------------------------------------------------------- done ---
say "Done"
cat <<'EOF'
  Remaining manual steps:
    - Run  :Copilot auth   in Neovim (credentials are machine-local).
    - For a work identity, create ~/.gitconfig-work:
          [user]
              email = you@work.example
      It is applied automatically to repos under ~/work and is not tracked here.

  Verify everything with:  ./check.sh
EOF
