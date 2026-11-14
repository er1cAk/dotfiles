#!/usr/bin/env bash
#
# Assert the invariants of this setup.
#
# Every check here exists because something actually went wrong once. In
# particular the keymap checks: the cheatsheet documented gsa/gsd/gsr while
# mini.surround was still on its default sa/sd/sr, and nothing caught it,
# because all verification at the time was throwaway one-liners.
#
# Run after ./install.sh on a new machine, and after touching the config.
#
set -uo pipefail

PASS=0; FAIL=0
ok()   { printf '  \033[32mPASS\033[0m %s\n' "$*"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }
head_() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

# ------------------------------------------------------------- alacritty ---
head_ "Alacritty"
if python3 -c "import tomllib,sys; tomllib.load(open('$HOME/.config/alacritty/alacritty.toml','rb'))" 2>/dev/null; then
  ok "alacritty.toml parses"
else
  bad "alacritty.toml does not parse"
fi

if grep -q 'Nerd Font Mono' "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null; then
  ok "font is a Mono nerd variant (icon ink fits one cell)"
else
  bad "font is not a 'Nerd Font Mono' variant -- icons will overflow and the cursor will clip them"
fi

if [[ -x "$HOME/.config/alacritty/tmux-session.sh" ]] && sh -n "$HOME/.config/alacritty/tmux-session.sh"; then
  ok "tmux-session.sh is executable and valid"
else
  bad "tmux-session.sh missing, not executable, or invalid"
fi

# ------------------------------------------------------------------ tmux ---
head_ "tmux"
KEYS="$(tmux -f "$HOME/.tmux.conf" -L checksh start-server \; list-keys 2>/dev/null)"
tmux -L checksh kill-server 2>/dev/null

if grep -qE 'prefix +x +confirm-before' <<<"$KEYS"; then
  ok "kill-pane asks for confirmation (Cmd-W is bound to this)"
else
  bad "kill-pane has NO confirmation -- Cmd-W would destroy a pane silently"
fi

if grep -qE 'prefix +X +confirm-before' <<<"$KEYS"; then
  ok "kill-window asks for confirmation"
else
  bad "kill-window has NO confirmation"
fi

# ---------------------------------------------------------------- neovim ---
head_ "Neovim"

NVIM_VER="$(nvim --version 2>/dev/null | head -1 | sed 's/^NVIM v//')"
if [[ -n "$NVIM_VER" && "$(printf '%s\n0.12.0\n' "$NVIM_VER" | sort -V | head -1)" == "0.12.0" ]]; then
  ok "neovim $NVIM_VER (>= 0.12 required by NvChad + treesitter main)"
else
  bad "neovim ${NVIM_VER:-not found} is below the required 0.12"
fi

STARTUP="$(nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 6000)' 2>&1)"
if [[ -z "$STARTUP" ]]; then
  ok "startup is clean (no errors, no deprecation warnings)"
else
  bad "startup produced output:"; sed 's/^/       /' <<<"$STARTUP" | head -6
fi

# Plugins must sit at their lockfile commits. On a fresh machine a single
# `Lazy! restore` left lazy.nvim and NvChad's imported plugins at upstream HEAD
# while every other check here still passed.
DRIFT="$(python3 - "$HOME/.config/nvim/lazy-lock.json" "$HOME/.local/share/nvim/lazy" <<'PY'
import json, os, subprocess, sys
lock, root = json.load(open(sys.argv[1])), sys.argv[2]
for name, entry in lock.items():
    head = subprocess.run(["git", "-C", os.path.join(root, name), "rev-parse", "HEAD"],
                          capture_output=True, text=True).stdout.strip()
    if head != entry["commit"]:
        print(f"{name} ({head[:8] or 'not installed'}, locked {entry['commit'][:8]})")
PY
)"
if [[ -z "$DRIFT" ]]; then
  ok "every plugin is at its lazy-lock.json commit"
else
  bad "plugins off their locked commit (run: nvim --headless '+Lazy! restore' +qa):"
  sed 's/^/       /' <<<"$DRIFT" | head -10
fi

cat > "$SCRATCH/keymaps.lua" <<'LUA'
local out = {}
local function m(k, mode)
  local r = vim.fn.maparg(k, mode or 'n', false, true)
  return (r and next(r)) and (r.desc or r.rhs or 'lua callback') or nil
end
vim.cmd('silent! Lazy! load mini.surround')

-- these must be UNMAPPED so Neovim 0.11+ built-ins stay reachable
for _, k in ipairs({ 'gr', 'K', ';' }) do
  out[#out+1] = (m(k) == nil and 'PASS ' or 'FAIL ') .. k .. ' unmapped'
end
-- built-in LSP keys must survive
for _, k in ipairs({ 'grn', 'gra', 'grr', 'gri', 'grt' }) do
  out[#out+1] = (m(k) ~= nil and 'PASS ' or 'FAIL ') .. k .. ' reaches the built-in'
end
-- surround must live on gs*, and s must NOT be a prefix (that delayed Flash)
for _, k in ipairs({ 'gsa', 'gsd', 'gsr' }) do
  out[#out+1] = (m(k) ~= nil and 'PASS ' or 'FAIL ') .. k .. ' mapped (matches the docs)'
end
for _, k in ipairs({ 'sa', 'sd', 'sr' }) do
  out[#out+1] = (m(k) == nil and 'PASS ' or 'FAIL ') .. k .. ' unmapped (s is not a prefix)'
end
out[#out+1] = (m('s') ~= nil and 'PASS ' or 'FAIL ') .. 's mapped to Flash'

-- the nvdash patch: 0 buttons means NvChad's internals moved and j/k will error
local okd, cfg = pcall(require, 'nvconfig')
local n = (okd and cfg.nvdash and cfg.nvdash.buttons) and #cfg.nvdash.buttons or 0
out[#out+1] = (n > 0 and 'PASS ' or 'FAIL ') .. 'nvdash defines ' .. n .. ' buttons'

-- Every server enabled in lspconfig.lua must have its binary installed.
-- This is THE check that was missing: angularls sat enabled-but-absent while
-- 7 Angular repos got no LSP at all, and the executable guard hid it silently.
--
-- Scope the match to the `local servers = { ... }` table -- matching the whole
-- file also picks up setting keys like typeCheckingMode = "standard".
local cfg_src = io.open(vim.fn.stdpath('config') .. '/lua/configs/lspconfig.lua'):read('a')
local servers_tbl = cfg_src:match('local servers = %{(.-)\n%}')
local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
local missing, enabled = {}, 0

if not servers_tbl then
  out[#out+1] = 'FAIL could not locate the servers table in lspconfig.lua'
else
  for server, bin in servers_tbl:gmatch('([%w_]+) = "([%w%-_.]+)"') do
    enabled = enabled + 1
    if vim.fn.executable(bin) ~= 1 and vim.fn.executable(mason_bin .. '/' .. bin) ~= 1 then
      missing[#missing+1] = server .. ' (' .. bin .. ')'
    end
  end
  out[#out+1] = (enabled > 0 and 'PASS ' or 'FAIL ') .. enabled .. ' LSP servers declared'
  out[#out+1] = (#missing == 0 and 'PASS ' or 'FAIL ')
    .. 'every enabled LSP has its binary installed'
    .. (#missing > 0 and (' -- MISSING: ' .. table.concat(missing, ', ')) or '')
end

-- debugging must exist for every language whose mappings we advertise
vim.cmd('silent! Lazy! load nvim-dap'); vim.cmd('silent! Lazy! load mason-nvim-dap.nvim')
vim.wait(2000)
local dap = require('dap')
for _, ft in ipairs({ 'go', 'python', 'javascript', 'typescript' }) do
  out[#out+1] = (dap.configurations[ft] and 'PASS ' or 'FAIL ') .. 'dap config for ' .. ft
end

print(table.concat(out, '\n'))
vim.cmd('qa!')
LUA

# `|| [[ -n "$line" ]]` matters: nvim --headless emits no trailing newline, so a
# plain `read` loop silently DROPS the final check rather than reporting it.
while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    PASS\ *) ok "${line#PASS }" ;;
    FAIL\ *) bad "${line#FAIL }" ;;
  esac
done < <(nvim --headless -c "luafile $SCRATCH/keymaps.lua" 2>&1)

# <leader>D must stay the database UI once a language server attaches: NvChad's
# on_attach rebinds it to type definition per buffer, and lspconfig.lua deletes
# that again. The keymap checks above run with no file open, so they cannot see it.
printf 'local x = 1\nreturn x\n' > "$SCRATCH/t.lua"
LEADER_D="$(cd "$SCRATCH" && nvim --headless t.lua \
  -c 'lua vim.wait(8000, function() return #vim.lsp.get_clients({bufnr=0}) > 0 end, 100); vim.wait(300)' \
  -c 'lua io.write(#vim.lsp.get_clients({bufnr=0}) .. " " .. (vim.fn.maparg("<leader>D", "n", false, true).desc or "none"))' \
  -c 'qa!' 2>&1)"
if [[ "$LEADER_D" =~ ^[1-9][0-9]*\ database\ UI\ toggle$ ]]; then
  ok "<leader>D opens the database UI in an LSP buffer"
elif [[ "$LEADER_D" == 0\ * ]]; then
  bad "no language server attached to a .lua file, so <leader>D could not be checked"
else
  bad "<leader>D in an LSP buffer is '${LEADER_D#* }', not the database UI"
fi

# ------------------------------------------------------------ formatting ---
head_ "Formatting"

# gofumpt vs gofmt: the Go repos this is used with enable gofmt + goimports, so
# gofumpt would silently reformat beyond what they expect. This input distinguishes
# them -- gofumpt rewrites 0666 to 0o666 and strips the blank line after '{'.
mkdir -p "$SCRATCH/go" && printf 'module t\n\ngo 1.21\n' > "$SCRATCH/go/go.mod"
cat > "$SCRATCH/go/m.go" <<'GO'
package main

import "fmt"

func main() {

	x := 0666
	fmt.Println(x)
}
GO
( cd "$SCRATCH/go" && nvim --headless m.go \
    -c 'lua vim.wait(5000, function() return #vim.lsp.get_clients({bufnr=0})>0 end, 200)' \
    -c 'lua require("conform").format({bufnr=0, timeout_ms=8000})' -c 'w' -c 'qa!' >/dev/null 2>&1 )

if grep -q '0666' "$SCRATCH/go/m.go" && sed -n '6p' "$SCRATCH/go/m.go" | grep -q '^$'; then
  ok "Go formats with gofmt, not gofumpt"
else
  bad "Go was reformatted by gofumpt -- will add unrelated noise to PRs"
fi

printf 'const x = {a:1,b:2}\n' > "$SCRATCH/t.ts"
nvim --headless "$SCRATCH/t.ts" -c 'lua require("conform").format({bufnr=0, timeout_ms=8000})' -c 'w' -c 'qa!' >/dev/null 2>&1
if grep -q 'a: 1' "$SCRATCH/t.ts"; then
  ok "TypeScript formats with prettierd"
else
  bad "TypeScript was not formatted"
fi

# --------------------------------------------------------------- dotfiles ---
head_ "Dotfiles"
for p in "$HOME/.config/nvim" "$HOME/.tmux.conf" "$HOME/.config/alacritty" "$HOME/.zshrc" "$HOME/.gitconfig" "$HOME/.config/starship.toml"; do
  if [[ -L "$p" ]]; then
    ok "$(basename "$p") is a symlink into the repo"
  else
    bad "$(basename "$p") is NOT a symlink -- stow has not been applied"
  fi
done

if ! grep -rqE '/Users/[a-z]+' "$HOME/dotfiles/zsh/.zshrc" "$HOME/dotfiles/git/.gitconfig" 2>/dev/null; then
  ok "no hardcoded home paths in tracked shell/git config"
else
  bad "hardcoded /Users/... paths remain -- will break under a different username"
fi

# The tracked .zshrc and .gitconfig are shared by every machine, so anything that
# only works on one of them belongs in ~/.zshrc.local or ~/.gitconfig.local. Both
# checks below were found setting up a second Mac: oh-my-zsh, starship and ng were
# absent there, and commit.gpgsign pointed at a gpg binary that was not installed.
#
# Run under a pseudo-terminal via script(1): without a TTY zle cannot start, and
# fzf's key-binding script then reports "can't change option: zle", an error a
# real terminal never shows. The tr/sed strip the ^D the pty echoes on EOF.
ZSH_ERR="$(script -q /dev/null zsh -i -c exit </dev/null 2>&1 | tr -d '\r\b' | sed 's/\^D//g' | grep -v '^[[:space:]]*$')"
if [[ -z "$ZSH_ERR" ]]; then
  ok "interactive zsh starts without errors"
else
  bad "zsh startup printed errors:"; sed 's/^/       /' <<<"$ZSH_ERR" | head -6
fi

if [[ "$(defaults read -g InitialKeyRepeat 2>/dev/null)" == 15 && "$(defaults read -g KeyRepeat 2>/dev/null)" == 2 ]]; then
  ok "key repeat at install.sh's values (225ms delay, then every 30ms)"
else
  bad "key repeat is not at install.sh's values: holding j/k in Neovim stays slow (re-run install.sh, then log out)"
fi

# starship reports a bad key or palette colour only when it renders, so a typo
# would otherwise surface as a warning on every prompt rather than here.
if [[ -z "$(STARSHIP_LOG=warn starship prompt 2>&1 >/dev/null)" ]]; then
  ok "starship.toml loads without warnings"
else
  bad "starship is missing or starship.toml has errors (run: starship prompt)"
fi

GPG_BIN="$(git config --get gpg.program || echo gpg)"
if [[ "$(git config --get commit.gpgsign)" != "true" ]] || command -v "$GPG_BIN" >/dev/null; then
  ok "commit signing is off, or its gpg binary exists"
else
  bad "commit.gpgsign is on but $GPG_BIN is missing: every commit will fail"
fi

# ------------------------------------------------------------------ done ---
printf '\n\033[1m%d passed, %d failed\033[0m\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
