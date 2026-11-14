# Curated, not `brew bundle dump`.
#
# This machine has 216 formulae / 13 casks, most unrelated to the terminal setup
# (krb5, flex, bison, old icu4c...). Dumping all of it would restore a decade of
# cruft onto a clean machine. This lists only what the setup actually needs.
#
# Run `brew bundle dump --force` separately if you ever want a full snapshot.

# terminal (Alacritty itself is installed by install.sh, see "Not listed on purpose")
cask "font-jetbrains-mono-nerd-font"
brew "tmux"

# editor -- NvChad and nvim-treesitter's `main` branch require Neovim >= 0.12
brew "neovim"
brew "tree-sitter-cli"        # nvim-treesitter compiles parsers with this

# tools the config shells out to
brew "fd"                     # telescope file finding
brew "ripgrep"                # telescope live grep
brew "lazygit"                # <leader>gg
brew "stow"                   # this repo's own install method
brew "git"
brew "starship"               # prompt; .zshrc inits it when present
brew "diff-so-fancy"          # .gitconfig pager and interactive.diffFilter
brew "git-lfs"                # .gitconfig declares the lfs filter required

# Not listed on purpose:
#   node    -- provided by nvm here; js-debug-adapter and prettierd need it on PATH
#   go      -- installed from go.dev at /usr/local/go, not Homebrew
#   alacritty: the cask was disabled 2026-09-01 (fails Gatekeeper), so
#           install.sh installs the pinned release DMG instead
