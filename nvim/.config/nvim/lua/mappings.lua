require "nvchad.mappings"

local map = vim.keymap.set
local del = function(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Two NvChad single-key leader maps collide with LazyVim's *groups*, so they
-- move one key deeper. Everything else NvChad binds is left untouched.
--   <leader>b (new buffer)   -> <leader>bn
--   <leader>x (close buffer) -> <leader>bd   (<leader>x is now the list group)
-- ═══════════════════════════════════════════════════════════════════════════
del("n", "<leader>b")
del("n", "<leader>x")

-- ── basics ────────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>", { desc = "escape insert mode" })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "save file" })

-- keep selection when indenting
map("v", "<", "<gv", { desc = "indent left and reselect" })
map("v", ">", ">gv", { desc = "indent right and reselect" })

-- move lines (LazyVim)
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "move line down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "move line up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "move selection down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "move selection up" })

-- centred scrolling / search (LazyVim feel)
map("n", "<C-d>", "<C-d>zz", { desc = "scroll down centred" })
map("n", "<C-u>", "<C-u>zz", { desc = "scroll up centred" })
map("n", "n", "nzzzv", { desc = "next search result centred" })
map("n", "N", "Nzzzv", { desc = "prev search result centred" })

-- ── file explorer ─────────────────────────────────────────────────────────
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "explorer toggle" })
map("n", "<leader>E", "<cmd>NvimTreeFocus<cr>", { desc = "explorer focus" })

-- ── buffers ───────────────────────────────────────────────────────────────
local tabufline = function(fn, ...)
  local args = { ... }
  return function()
    require("nvchad.tabufline")[fn](unpack(args))
  end
end

map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "buffer new" })
map("n", "<leader>bd", tabufline "close_buffer", { desc = "buffer delete" })
map("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "buffer delete (force)" })
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "buffer switch to other" })
map("n", "<leader>bo", tabufline("closeAllBufs", false), { desc = "buffer delete others" })
map("n", "<leader>ba", tabufline("closeAllBufs", true), { desc = "buffer delete all" })
map("n", "]b", tabufline "next", { desc = "buffer next" })
map("n", "[b", tabufline "prev", { desc = "buffer prev" })

-- ── find / files (telescope) ──────────────────────────────────────────────
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "find by grep" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "find recent files" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "new file" })
map("n", "<leader>fF", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<cr>", { desc = "find all files" })
map("n", "<leader>fc", function()
  require("telescope.builtin").find_files { cwd = vim.fn.stdpath "config" }
end, { desc = "find nvim config file" })
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "recent projects" })

-- ── search (LazyVim <leader>s group) ──────────────────────────────────────
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "search grep" })
map("n", "<leader>sw", "<cmd>Telescope grep_string<cr>", { desc = "search word under cursor" })
map("v", "<leader>sw", "<cmd>Telescope grep_string<cr>", { desc = "search selection" })
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "search in buffer" })
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "search keymaps" })
map("n", "<leader>sc", "<cmd>Telescope commands<cr>", { desc = "search commands" })
map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "search help" })
map("n", "<leader>sm", "<cmd>Telescope marks<cr>", { desc = "search marks" })
map("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "search buffer diagnostics" })
map("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "search all diagnostics" })
map("n", "<leader>sR", "<cmd>Telescope resume<cr>", { desc = "search resume" })
map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "search document symbols" })
map("n", "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "search workspace symbols" })
map("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "search todo comments" })
map("n", "<leader>sr", "<cmd>Telescope registers<cr>", { desc = "search registers" })

-- ── code / LSP (LazyVim <leader>c group) ──────────────────────────────────
-- No `gr` / `K` / insert `<C-k>` here on purpose: Neovim 0.11+ provides grn/gra/grr/
-- gri/grt, K (with keywordprg fallback) and insert <C-s> natively. Mapping `gr` makes
-- it both a mapping and a prefix, so every gr* built-in races timeoutlen.
map("n", "gI", vim.lsp.buf.implementation, { desc = "goto implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "goto type definition" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "signature help" })

map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "code action" })
map("n", "<leader>cr", function()
  require "nvchad.lsp.renamer"()
end, { desc = "code rename" })
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format { lsp_fallback = true, async = false, timeout_ms = 1000 }
end, { desc = "code format" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "code line diagnostics" })
map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { desc = "code LSP info" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "code symbols outline" })

-- diagnostic navigation
map("n", "]d", function() vim.diagnostic.jump { count = 1, float = true } end, { desc = "next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump { count = -1, float = true } end, { desc = "prev diagnostic" })
map("n", "]e", function() vim.diagnostic.jump { count = 1, float = true, severity = vim.diagnostic.severity.ERROR } end, { desc = "next error" })
map("n", "[e", function() vim.diagnostic.jump { count = -1, float = true, severity = vim.diagnostic.severity.ERROR } end, { desc = "prev error" })

-- quickfix navigation
map("n", "]q", "<cmd>cnext<cr>", { desc = "next quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "prev quickfix" })

-- ── git ───────────────────────────────────────────────────────────────────
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "lazygit" })
map("n", "<leader>gf", "<cmd>LazyGitFilterCurrentFile<cr>", { desc = "lazygit file history" })
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "git status" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "git commits" })
map("n", "<leader>gB", "<cmd>Telescope git_branches<cr>", { desc = "git branches" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "git diff view" })
map("n", "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", { desc = "git file history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "git close diff view" })

local function gs(fn, ...)
  local args = { ... }
  return function()
    require("gitsigns")[fn](unpack(args))
  end
end
map("n", "<leader>gb", gs "blame_line", { desc = "git blame line" })
map("n", "<leader>gp", gs "preview_hunk", { desc = "git preview hunk" })
map("n", "<leader>gr", gs "reset_hunk", { desc = "git reset hunk" })
map("n", "<leader>gS", gs "stage_hunk", { desc = "git stage hunk" })
map("n", "]h", gs("nav_hunk", "next"), { desc = "next git hunk" })
map("n", "[h", gs("nav_hunk", "prev"), { desc = "prev git hunk" })

-- ── diagnostics / lists (LazyVim <leader>x group) ─────────────────────────
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "buffer diagnostics (trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>", { desc = "workspace diagnostics (trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "location list (trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "quickfix list (trouble)" })
map("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "todo list (trouble)" })
map("n", "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", { desc = "todo/fix list (trouble)" })

-- ── UI toggles (LazyVim <leader>u group) ──────────────────────────────────
local function toggle(opt, label)
  return function()
    vim.opt_local[opt] = not vim.opt_local[opt]:get()
    vim.notify((label or opt) .. ": " .. tostring(vim.opt_local[opt]:get()), vim.log.levels.INFO)
  end
end

map("n", "<leader>uw", toggle("wrap", "wrap"), { desc = "toggle wrap" })
map("n", "<leader>us", toggle("spell", "spell"), { desc = "toggle spelling" })
map("n", "<leader>ul", toggle("number", "line numbers"), { desc = "toggle line numbers" })
map("n", "<leader>uL", toggle("relativenumber", "relative numbers"), { desc = "toggle relative numbers" })
map("n", "<leader>uc", toggle("cursorline", "cursorline"), { desc = "toggle cursorline" })

map("n", "<leader>ud", function()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  vim.notify("diagnostics: " .. tostring(not enabled), vim.log.levels.INFO)
end, { desc = "toggle diagnostics" })

map("n", "<leader>uf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("format on save: " .. tostring(not vim.g.disable_autoformat), vim.log.levels.INFO)
end, { desc = "toggle format on save" })

map("n", "<leader>uh", function()
  local on = vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
  vim.lsp.inlay_hint.enable(not on, { bufnr = 0 })
  vim.notify("inlay hints: " .. tostring(not on), vim.log.levels.INFO)
end, { desc = "toggle inlay hints" })

map("n", "<leader>ug", function()
  require("gitsigns").toggle_signs()
end, { desc = "toggle git signs" })

map("n", "<leader>ut", function()
  require("nvchad.themes").open()
end, { desc = "toggle theme picker" })

-- ── windows (LazyVim <leader>w group) ─────────────────────────────────────
map("n", "<leader>wd", "<C-w>c", { desc = "window delete" })
map("n", "<leader>ww", "<C-w>p", { desc = "window other" })
map("n", "<leader>w-", "<C-w>s", { desc = "window split below" })
map("n", "<leader>w|", "<C-w>v", { desc = "window split right" })
map("n", "<leader>w=", "<C-w>=", { desc = "window equalise" })

-- resize with arrows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "increase window width" })

-- ── quit / sessions (LazyVim <leader>q group) ─────────────────────────────
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "quit all" })
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "restore session" })
map("n", "<leader>ql", function() require("persistence").load { last = true } end, { desc = "restore last session" })
map("n", "<leader>qS", function() require("persistence").select() end, { desc = "select session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "don't save current session" })

-- ── tests (neotest) ───────────────────────────────────────────────────────
map("n", "<leader>tt", function() require("neotest").run.run(vim.fn.expand "%") end, { desc = "test run file" })
map("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "test run nearest" })
map("n", "<leader>tl", function() require("neotest").run.run_last() end, { desc = "test run last" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "test summary toggle" })
map("n", "<leader>to", function() require("neotest").output.open { enter = true, auto_close = true } end, { desc = "test show output" })
map("n", "<leader>tO", function() require("neotest").output_panel.toggle() end, { desc = "test output panel" })
map("n", "<leader>tS", function() require("neotest").run.stop() end, { desc = "test stop" })
map("n", "<leader>td", function() require("neotest").run.run { strategy = "dap" } end, { desc = "test debug nearest" })

-- ── debug (nvim-dap) ──────────────────────────────────────────────────────
local function dap(fn, ...)
  local args = { ... }
  return function()
    require("dap")[fn](unpack(args))
  end
end

map("n", "<leader>db", dap "toggle_breakpoint", { desc = "debug toggle breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "debug conditional breakpoint" })
map("n", "<leader>dc", dap "continue", { desc = "debug continue" })
map("n", "<leader>dC", dap "run_to_cursor", { desc = "debug run to cursor" })
map("n", "<leader>di", dap "step_into", { desc = "debug step into" })
map("n", "<leader>dO", dap "step_over", { desc = "debug step over" })
map("n", "<leader>do", dap "step_out", { desc = "debug step out" })
map("n", "<leader>dt", dap "terminate", { desc = "debug terminate" })
map("n", "<leader>dr", dap "repl.toggle", { desc = "debug toggle REPL" })
map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "debug toggle UI" })
map("n", "<leader>dg", function() require("dap-go").debug_test() end, { desc = "debug go test" })

-- ── AI / Copilot (LazyVim <leader>a group) ────────────────────────────────
map({ "n", "v" }, "<leader>aa", "<cmd>CopilotChatToggle<cr>", { desc = "copilot chat toggle" })
map({ "n", "v" }, "<leader>ae", "<cmd>CopilotChatExplain<cr>", { desc = "copilot explain" })
map({ "n", "v" }, "<leader>af", "<cmd>CopilotChatFix<cr>", { desc = "copilot fix" })
map({ "n", "v" }, "<leader>ar", "<cmd>CopilotChatReview<cr>", { desc = "copilot review" })
map({ "n", "v" }, "<leader>at", "<cmd>CopilotChatTests<cr>", { desc = "copilot generate tests" })
map({ "n", "v" }, "<leader>ao", "<cmd>CopilotChatOptimize<cr>", { desc = "copilot optimize" })
map("n", "<leader>ac", "<cmd>CopilotChatCommit<cr>", { desc = "copilot commit message" })
map("n", "<leader>ap", "<cmd>Copilot panel<cr>", { desc = "copilot panel" })
map("n", "<leader>as", "<cmd>Copilot status<cr>", { desc = "copilot status" })

-- ── plugin manager / tooling ──────────────────────────────────────────────
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "lazy plugin manager" })
map("n", "<leader>lm", "<cmd>Mason<cr>", { desc = "mason tool manager" })

-- ── terminal (LazyVim's <C-/>) ────────────────────────────────────────────
map({ "n", "t" }, "<C-/>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating" })
map({ "n", "t" }, "<C-_>", function() -- some terminals send <C-_> for <C-/>
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating" })
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- ── which-key group labels ────────────────────────────────────────────────
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local ok, wk = pcall(require, "which-key")
    if not ok or not wk.add then
      return
    end
    wk.add {
      { "<leader>a", group = "ai / copilot" },
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>f", group = "find / file" },
      { "<leader>g", group = "git" },
      { "<leader>l", group = "lazy / mason" },
      { "<leader>q", group = "quit / session" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "test / theme" },
      { "<leader>u", group = "ui toggles" },
      { "<leader>w", group = "window / workspace" },
      { "<leader>x", group = "diagnostics / lists" },
      { "[", group = "prev" },
      { "]", group = "next" },
    }
  end,
})

-- ── user commands ─────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { desc = "Disable format on save (! = current buffer only)", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Re-enable format on save" })

vim.api.nvim_create_user_command("MasonExtras", function()
  vim.cmd "MasonInstall jdtls kotlin-language-server intelephense ansible-language-server helm-ls cmake-language-server astro-language-server angular-language-server sql-language-server"
end, { desc = "Install the less-common language servers (java, kotlin, php, ansible, helm, cmake, astro, angular, sql)" })
