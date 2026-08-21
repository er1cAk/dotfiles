require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- ── carried over from the previous LazyVim setup ──────────────────────────
-- no auto-comment continuation, no auto-wrap of code
opt.formatoptions = "jqlnt"

-- ── general editing ───────────────────────────────────────────────────────
o.cursorlineopt = "both" -- highlight the whole cursor line
o.relativenumber = true  -- LazyVim default
o.scrolloff = 4
o.sidescrolloff = 8
o.confirm = true         -- ask instead of failing on unsaved quit
o.undofile = true
o.wrap = false
o.linebreak = true
o.splitbelow = true
o.splitright = true
o.termguicolors = true

-- indentation (LazyVim defaults)
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

-- search
o.ignorecase = true
o.smartcase = true
o.inccommand = "nosplit" -- live preview of :s

-- timings
o.updatetime = 200
o.timeoutlen = 300

-- system clipboard (LazyVim behaviour)
opt.clipboard = "unnamedplus"

-- nicer diffs / folds via treesitter
opt.fillchars = {
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
o.foldlevel = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""

-- spelling in prose only (see autocmds)
o.spelllang = "en_us"

-- give the ruler a hint at 80/120 cols without being loud
opt.colorcolumn = ""
