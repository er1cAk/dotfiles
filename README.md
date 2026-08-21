# dotfiles

Alacritty + tmux + NvChad on macOS. Catppuccin Mocha throughout.

## Restore on a new Mac

```sh
git clone https://github.com/er1cAk/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh          # ~10 minutes, mostly plugin/LSP/parser downloads
./check.sh            # 33 assertions; everything should pass
```

Then two manual steps `install.sh` prints and cannot do for you:

- `:Copilot auth` in Neovim — credentials are machine-local by design.
- Create `~/.gitconfig-work` if this machine does work repos (see *Git identity*).

## The stack this targets

Tooling is chosen for this and nothing else — anything without evidence of use in my
repos gets removed rather than carried:

| | |
|---|---|
| Go | gopls, delve, neotest-go. `gofmt` + `goimports` (**not** gofumpt) |
| Python | uv, basedpyright + ruff, debugpy. Project `.venv` auto-activates |
| TS/JS | node/pnpm/nvm, ts_ls, eslint, prettierd, js-debug |
| Frontend | Angular, React, React Native, Next.js — angularls, tailwind, emmet |
| Data | Postgres + SQLite via vim-dadbod; Drizzle (not Prisma) |
| Infra | terraform, helm, docker |
| PHP | intelephense, for one legacy service |
| Markdown | in-buffer rendering; images and mermaid via browser preview |

Inngest and Infisical need no editor tooling — the first is a TypeScript SDK already
covered by `ts_ls`, the second is a CLI.

## Requirements

- **macOS** with Homebrew and Xcode Command Line Tools (`xcode-select --install`).
  The CLT are not optional: tree-sitter compiles parsers from source.
- **Neovim ≥ 0.12**, enforced by `install.sh`. NvChad ships nvim-treesitter's `main`
  branch, which calls APIs (`vim.list.unique`) that don't exist in 0.11.
- **Node** on `PATH` — `prettierd` and `js-debug-adapter` need it. Provided by nvm here,
  deliberately not in the `Brewfile`.

## Layout

Stow packages; each mirrors `$HOME`.

```
nvim/.config/nvim/              editor config + lazy-lock.json
alacritty/.config/alacritty/    alacritty.toml + tmux-session.sh
tmux/.tmux.conf
zsh/.zshrc
git/.gitconfig + .config/git/ignore
```

`stow` symlinks these into place, so **editing `~/.config/nvim` edits this repo** — there
is no apply step, just commit.

To add a package: `stow --dir=~/dotfiles --target=$HOME --restow <name>`.

**Never use `stow --adopt`.** It resolves conflicts by overwriting *this repo* with
whatever is on the machine, silently discarding the good version. `install.sh` detects
conflicts and aborts instead.

## What is deliberately not tracked

| | why |
|---|---|
| `~/.local/share/nvim` (~1.9 GB) | plugins, Mason tools and parsers — all regenerable from `lazy-lock.json` |
| `~/.config/github-copilot/` | machine-local credentials |
| project.nvim history | machine-specific, and it lists private repo names |
| `~/.gitconfig-work` | holds a work email address |

## Reproducibility

Three layers, pinned to different degrees on purpose:

- **Plugins — pinned.** `lazy-lock.json` holds exact commits for 56 plugins.
  `install.sh` runs `Lazy! restore`, never `Lazy! sync`. *`sync` updates everything and
  rewrites the lockfile*, which defeats the point.
- **Formatters — pinned.** `prettierd`, `stylua`, `shfmt`, `sql-formatter`, `ruff` and
  `goimports` carry explicit versions in `lua/plugins/init.lua`. They rewrite file
  contents, so a version difference between machines shows up as spurious diffs in PRs.
- **Language servers — deliberately floating.** They affect diagnostics, not bytes on
  disk, so drift costs nothing and pinning them is maintenance for no benefit.

NvChad itself tracks its `v2.5` branch rather than a fixed commit — pinning would freeze
out upstream fixes. The safety net is `check.sh` plus a runtime warning (see below).

## Things worth knowing before you change something

- **Font must be a `Nerd Font Mono` variant.** In the plain family, icon glyphs draw ink at
  ~155% of the cell width while advancing only one cell, so icons bleed into neighbours
  and the block cursor visibly clips them. `check.sh` asserts this.
- **Go formats with `gofmt`, not `gofumpt`** — the Go repos I work in enable
  `gofmt` + `goimports` in `.golangci.yml`. gofumpt is stricter and quietly reformats
  beyond what those repos expect, adding unrelated noise to PRs. `check.sh` asserts this with an input the
  two formatters disagree on.
- **`gr`, `K` and `;` are intentionally unmapped.** Neovim 0.11+ provides `grn`/`gra`/
  `grr`/`gri`/`grt`, `K` with a `keywordprg` fallback, and insert-mode `<C-s>`. Mapping
  `gr` makes it both a mapping and a prefix, so every `gr*` built-in races `timeoutlen`.
- **mini.surround lives on `gs*`, not its default `s*`** — `s` is Flash, and mini's
  defaults would make `s` a prefix, delaying every jump by `timeoutlen`.
- **`lua/autocmds.lua` patches NvChad's dashboard.** It fixes an upstream crash
  (`E5108`, `key_movements` returning `nil` into `nvim_win_set_cursor`) and adds the
  padded selection highlight. It depends on NvChad internals and **warns loudly** if they
  change, rather than silently reverting to the crash.

## Git identity

`.gitconfig` carries the personal identity. Repos under `~/work` pick up a separate,
untracked file:

```
# ~/.gitconfig-work
[user]
    email = you@work.example
```

Applied via `includeIf "gitdir:~/work/"`. Git ignores the block if the file is absent.

Global ignores live at `~/.config/git/ignore` (the XDG path git reads automatically).
`core.excludesfile` is deliberately unset — it previously pointed at an absolute
`/Users/…` path while a second, unused ignore file sat at the XDG location.

## Documentation

| | |
|---|---|
| [`docs/keymap.html`](docs/keymap.html) | Searchable keybinding reference — open it in a browser: `open ~/dotfiles/docs/keymap.html`. Generated from the live config, filters as you type. |
| [`docs/CHEATSHEET.md`](docs/CHEATSHEET.md) | The same reference in markdown, plus setup notes and rollback steps. |

Both are generated from what the config actually binds, not from memory —
`nvim_get_keymap` is the source, and the keys are cross-checked against it before
either file is updated. An earlier hand-written version drifted from reality within a day.
