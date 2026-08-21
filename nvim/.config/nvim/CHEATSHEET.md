# Terminal + Editor setup

> **Searchable web version:** https://claude.ai/code/artifact/3ff8b5df-4807-4d48-b32d-64c7a6a97f43
> A local copy lives at `nvim/.config/nvim/keymap.html` — `open ~/.config/nvim/keymap.html`.
> It filters live, so it beats scrolling this file when you're hunting one key.

Alacritty (Catppuccin Mocha, JetBrainsMono Nerd Font 16) → tmux session `main` → NvChad.

Everything below is what *your* config binds. `<leader>` is **Space**.

---

## Alacritty

| Key | Action |
|---|---|
| `Cmd-N` | New Alacritty window — gets its **own** tmux session (`main-2`, …) |
| `Cmd-Return` | Toggle fullscreen |
| `Cmd-+` / `Cmd--` / `Cmd-0` | Font size up / down / reset |
| `Cmd-K` | Clear scrollback |
| `Cmd-F` / `Cmd-B` | Search forward / backward |
| `Ctrl-Shift-Space` | Vi mode (scroll & select with hjkl) |
| `Cmd-C` / `Cmd-V` | Copy / paste |

Config: `~/.config/alacritty/alacritty.toml` — **live reload is on**, edits apply on save.

**Tuning the text density.** JetBrains Mono has a tall line box (0.600em advance against
a 1.32em line, cell ratio 0.45), so it reads narrow by default. Two knobs, both under
`[font.offset]`:

- `x` widens each cell — currently `1`, which takes the ratio to 0.50. Raise for airier
  text, drop to `0` for the font's native density.
- `y` adds space *between* lines. It does **not** widen glyphs, so raising it makes text
  look taller and more squeezed. Left at `0` deliberately.

If you'd rather have a squarer typeface, `SauceCodePro Nerd Font Mono` (ratio 0.48,
already installed) is a drop-in swap for the four `family =` lines.

**Keep the `Mono` suffix on whatever font you pick.** In the plain `JetBrainsMono Nerd
Font` family, icon glyphs draw ink at ~155% of the cell width while still advancing only
one cell — so icons bleed into the next cell and the block cursor visibly clips them. The
`Mono` variants scale icon ink to exactly one cell. Icons render a little smaller; they
also line up.

The Option key sends Alt (`option_as_alt = "Both"`), which is what makes `<A-j>`/`<A-k>`
work in Neovim and tmux.

---

## tmux — prefix is `Ctrl-a`

Alacritty opens straight into a persistent session called `main`. Close the window and
reopen it; your shells, running processes and scrollback are still there.

| Key | Action |
|---|---|
| `Cmd-T` | New window (tab) |
| `Cmd-D` | Split right |
| `Cmd-Shift-D` | Split down |
| `Cmd-W` | Close pane — **prompts first** |
| `Cmd-1..5` | Jump to window 1–5 |
| `Cmd-Shift-[` / `]` | Previous / next window |
| `Alt-←` / `Alt-→` | Previous / next window |

Prefix bindings (`Ctrl-a` then the key):

| Key | Action |
|---|---|
| `c` | New window · `x` close pane · `X` close window |
| `\|` `-` | Split right / down (keeps current directory) |
| `h j k l` | Move between panes |
| `H J K L` | Resize pane (repeatable) |
| `z` | Zoom pane fullscreen (toggle) |
| `Enter` | Copy mode — `v` select, `y` yank to macOS clipboard, `Esc` cancel |
| `d` | Detach (session keeps running) |
| `r` | Reload `~/.tmux.conf` |

Mouse is on: click panes, drag borders, scroll, drag-select to copy.

From any shell: `tmux ls`, `tmux attach -t main`, `tmux kill-server`.

---

## Neovim (NvChad + LazyVim bridge)

Two NvChad keys moved one level deeper so LazyVim's *groups* work:

- `<leader>b` (new buffer) → **`<leader>bn`**
- `<leader>x` (close buffer) → **`<leader>bd`** — `<leader>x` is now the diagnostics group

Everything else NvChad binds is untouched, and the LazyVim keys you reflex to are added
on top. Press `<leader>` and wait to see the which-key menu, or `<leader>ch` for
NvChad's cheatsheet.

### Files & search

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fF` | Find files (incl. hidden/ignored) |
| `<leader>fg` / `<leader>sg` / `<leader>fw` | Live grep |
| `<leader>fr` / `<leader>fo` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>fc` | Find a file in your nvim config |
| `<leader>fp` | Recent projects |
| `<leader>sw` | Grep word under cursor (works on a visual selection too) |
| `<leader>sb` | Fuzzy find in current buffer |
| `<leader>sk` `<leader>sc` `<leader>sh` | Keymaps / commands / help |
| `<leader>sd` `<leader>sD` | Diagnostics: buffer / workspace |
| `<leader>ss` `<leader>sS` | Symbols: document / workspace |
| `<leader>sR` | Resume last picker |
| `<leader>st` | TODO comments |
| `<leader>e` / `<C-n>` | Toggle file tree · `<leader>E` focus it |

### Buffers & windows

| Key | Action |
|---|---|
| `<leader>bd` | Close buffer · `<leader>bD` force |
| `<leader>bn` | New buffer · `<leader>bb` previous buffer |
| `<leader>bo` / `<leader>ba` | Close other / all buffers |
| `Tab` / `Shift-Tab` / `]b` / `[b` | Cycle buffers |
| `<C-h/j/k/l>` | Move between splits |
| `<leader>w-` `<leader>w\|` | Split below / right |
| `<leader>wd` `<leader>ww` `<leader>w=` | Close / other / equalise |
| `<C-arrows>` | Resize split |

### Code / LSP

| Key | Action |
|---|---|
| `gd` `gD` `gI` `gy` | Definition, declaration, implementation, type definition |
| `grr` `gri` `grt` `grn` `gra` | References, implementation, type def, rename, code action — **Neovim built-ins** |
| `K` / `gK` | Hover docs / signature help (built-in `K` also falls back to `:help`) |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename (NvChad's renamer popup) |
| `<leader>cf` / `<leader>fm` | Format buffer |
| `<leader>cd` | Line diagnostics float |
| `<leader>cs` | Symbol outline (Trouble) |
| `]d` `[d` / `]e` `[e` | Next/prev diagnostic / error |
| `<leader>xx` `<leader>xX` | Trouble: buffer / workspace diagnostics |
| `<leader>xL` `<leader>xQ` `<leader>xt` | Loclist / quickfix / todos |

**Go formats with `gofmt`, not `gofumpt`** — the Go repos I work in enable `gofmt` +
`goimports` in `.golangci.yml`, and gofumpt is stricter, so it would quietly reformat
beyond what those repos expect and add noise to PRs.

**Format on save is on** (conform.nvim). Toggle it with `<leader>uf`, or
`:FormatDisable` / `:FormatDisable!` (buffer only) / `:FormatEnable`.

### Git

| Key | Action |
|---|---|
| `<leader>gg` | LazyGit · `<leader>gf` file history |
| `<leader>gs` `<leader>gc` `<leader>gB` | Status / commits / branches (telescope) |
| `<leader>gd` `<leader>gD` `<leader>gq` | Diffview: open / file history / close |
| `<leader>gb` `<leader>gp` | Blame line / preview hunk |
| `<leader>gS` `<leader>gr` | Stage / reset hunk |
| `]h` `[h` | Next / previous hunk |

### AI (Copilot)

Suggestions appear inside the completion menu. Chat:

| Key | Action |
|---|---|
| `<leader>aa` | Toggle Copilot Chat |
| `<leader>ae` `<leader>af` `<leader>ar` | Explain / fix / review (works on a selection) |
| `<leader>at` `<leader>ao` | Generate tests / optimize |
| `<leader>ac` | Write a commit message |
| `<leader>as` | Copilot status |

If Copilot isn't authenticated: `:Copilot auth`.

### Tests & debugging

| Key | Action |
|---|---|
| `<leader>tr` `<leader>tt` `<leader>tl` | Run nearest / file / last |
| `<leader>ts` `<leader>to` `<leader>tO` | Summary / output / output panel |
| `<leader>td` `<leader>tS` | Debug nearest / stop |
| `<leader>db` `<leader>dB` | Breakpoint / conditional breakpoint |
| `<leader>dc` `<leader>di` `<leader>dO` `<leader>do` | Continue / step into / over / out |
| `<leader>du` `<leader>dr` `<leader>dt` | Toggle UI / REPL / terminate |
| `<leader>dg` | Debug Go test |

**Test** adapters: jest, vitest, go, python.

**Debug** adapters: Go (delve), Python (debugpy), JS/TS/TSX (js-debug / `pwa-node`).
Each has launch and attach configurations. `mason-nvim-dap` wires Go and Python; the
JS adapter is registered by hand in `lua/plugins/dap.lua` because mason-nvim-dap ships
no `js` adapter definition.

### UI toggles & sessions

| Key | Action |
|---|---|
| `<leader>uw` `<leader>us` | Wrap / spelling |
| `<leader>ul` `<leader>uL` `<leader>uc` | Line numbers / relative / cursorline |
| `<leader>ud` `<leader>uf` `<leader>uh` `<leader>ug` | Diagnostics / format-on-save / inlay hints / git signs |
| `<leader>th` or `<leader>ut` | Theme picker (live preview of every base46 theme) |
| `<leader>qs` `<leader>ql` `<leader>qS` | Restore session (cwd / last / pick) |
| `<leader>qq` | Quit all |

### Editing

| Key | Action |
|---|---|
| `jk` | Escape from insert mode |
| `<C-s>` | Save |
| `s` / `S` | Flash jump / treesitter jump |
| `<A-j>` `<A-k>` | Move line or selection up/down |
| `<` `>` in visual | Indent and keep the selection |
| `<leader>/` | Toggle comment (`gcc` / `gc` also work) |
| `gsa` `gsd` `gsr` | Surround add / delete / replace |
| `<C-s>` (insert) | Signature help (Neovim built-in) |
| `;` / `,` | Repeat / reverse last `f`/`t` motion (Vim default, restored) |
| `<C-/>` or `<A-i>` | Floating terminal |
| `<A-h>` / `<A-v>` | Horizontal / vertical terminal |

### Dashboard

`j`/`k`/`<up>`/`<down>` move between buttons and wrap at the ends; `<cr>` runs the
selected one. Clicking anywhere on the dashboard snaps the cursor to the nearest button.
The selected button gets a padded highlight and the block cursor is hidden while the
dashboard is focused (it is restored on the way out, including on exit).

**Recent Projects** is `project.nvim` + `:Telescope projects` — the same plugin behind
LazyVim's old `util.project` extra. Roots are detected from marker files (`.git`,
`package.json`, `go.mod`, `pyproject.toml`, ...). The history was seeded with the 56 git
repos already under `~/work`, so the list is useful immediately rather than starting
empty; it updates itself as you open things.

Detection is set to `pattern` only, not `lsp`: the LSP method calls the removed
`vim.lsp.buf_get_clients()` and prints a deprecation warning on every startup under
Neovim 0.12.

These four mappings are replacements for nvdash's own, which crash with
`E5108: Expected 2 arguments` whenever the cursor sits off a button row — easy to trigger
now that the mouse is enabled. See the `nvdash_fix` block in `lua/autocmds.lua`. If a
future NvChad release fixes this upstream, that block can simply be deleted.

### Stack tooling

| Key | Action |
|---|---|
| `<leader>D` | Database UI (Postgres / SQLite / MySQL) |
| `<leader>cv` | Pick a Python venv |
| `<leader>um` | Toggle markdown rendering in the buffer |
| `<leader>mp` | Markdown preview in the browser |

**Database.** `:DBUI` browses schemas and runs queries; `<leader>S` executes the query
under the cursor. Add a connection with `:DBUIAddConnection`, e.g.
`postgres://user@localhost/dbname` or `sqlite:./dev.db`. Inside `.sql` buffers you get
table and column completion. `psql`, `sqlite3` and `mysql` are already installed.

**Python venvs.** The project's `.venv` (the one `uv` creates) is **activated
automatically** when you open a Python file, so basedpyright resolves third-party imports
without being asked. `<leader>cv` overrides it manually.

**Markdown.** The buffer renders headings, tables, checkboxes and callouts in place.
**Images and mermaid diagrams need `<leader>mp`** — Alacritty cannot draw inline images
(it implements neither sixel nor the kitty graphics protocol), so those render in the
browser instead.

**package.json.** Open one and dependency versions appear inline. Keys are buffer-local
so they don't collide with `<leader>n` (line-number toggle): `<leader>ns` show,
`<leader>nh` hide, `<leader>nu` update, `<leader>nd` delete, `<leader>ni` install,
`<leader>nc` change version.

### Housekeeping

| Command | Purpose |
|---|---|
| `<leader>l` | Lazy (plugin manager) |
| `<leader>lm` | Mason (LSP/tool installer) |
| `:checkhealth` | Diagnose problems |

---

## What's installed

**Language servers (21, all verified installed by `check.sh`):** lua, typescript/
javascript, eslint, **angular**, html, css, json, emmet, tailwind, gopls, basedpyright,
ruff, **intelephense** (php), yaml, taplo (toml), marksman (markdown), bash, dockerfile,
docker-compose, terraform, **helm**.

**Formatters:** stylua, prettierd, gofmt, goimports, shfmt, sql-formatter, ruff.

**Debug adapters:** delve (Go), js-debug-adapter (node/browser).

**Removed as dead weight** (verified zero usage in `~/work`): prisma (you use Drizzle —
0 `schema.prisma` files), astro, cmake, java, kotlin, vue, svelte, ansible, and the SQL
language server (dadbod does it better). Haskell was never installed.

**Also changed on your machine:**

- Neovim upgraded `0.11.5 → 0.12.4`. NvChad now ships nvim-treesitter's rewritten `main`
  branch, which uses APIs that only exist in 0.12.
- `tree-sitter-cli` installed via brew — the new nvim-treesitter compiles parsers with it
  rather than bundling them. Without it, `:TSInstall` fails with `ENOENT: 'tree-sitter'`.
- Alacritty's terminfo copied to `~/.terminfo/61/` so `TERM=alacritty` resolves.
- `alacritty` symlinked into `/opt/homebrew/bin` so it works from the command line.

One thing worth knowing: your `~/.zshrc` takes ~1.5s to load (nvm, sdkman, and
`source <(ng completion script)` are the expensive ones). That delay now shows on every
new tmux window. Lazy-loading nvm would win most of it back if it starts to bother you.

---

## Files

```
~/.config/alacritty/alacritty.toml   terminal
~/.tmux.conf                         multiplexer
~/.config/nvim/
  lua/chadrc.lua                     theme + NvChad UI
  lua/options.lua                    vim options
  lua/mappings.lua                   keymaps (the LazyVim bridge lives here)
  lua/autocmds.lua                   autocommands
  lua/configs/lspconfig.lua          LSP servers + diagnostics
  lua/configs/conform.lua            formatters + format-on-save
  lua/plugins/*.lua                  plugin specs
```

## Dotfiles

This config lives in `~/dotfiles` and is symlinked here by GNU Stow, so **editing these
files edits the repo** — no apply step, just commit.

```sh
cd ~/dotfiles && ./check.sh     # 33 assertions
git add -A && git commit        # your edits are already staged-able
```

Restoring on another Mac: `git clone … ~/dotfiles && cd ~/dotfiles && ./install.sh`.
See `~/dotfiles/README.md` for requirements and what is deliberately not tracked.

## Rolling back

Your LazyVim setup was moved aside, not deleted:

```
~/.config/nvim.lazyvim.bak-20260820-222701      (80K, kept)
```

The original 9-line Alacritty config lives in this repo's git history rather than a
`.bak` file: `git log --follow alacritty/.config/alacritty/alacritty.toml`.

The 80K config backup contains `lazy-lock.json` pinning all 79 LazyVim plugins, so the
whole setup restores from it alone. The 3.5 GB of plugin/Mason data and 206 MB of state
that sat alongside it were regenerable and have been deleted; the 3,039 undo files were
rescued into `~/.local/state/nvim/undo` first, so undo history survived.

To go back: move the config backup to `~/.config/nvim` and run `:Lazy restore`.
