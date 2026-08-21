require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("erik_" .. name, { clear = true })
end

-- ── carried over from the previous LazyVim setup ──────────────────────────
-- ftplugin files keep re-adding auto-commenting; strip it on every buffer.
autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  group = augroup "no_auto_comment",
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove { "c", "r", "o" }
  end,
})

-- ── quality of life (LazyVim-equivalent behaviours) ───────────────────────

-- briefly highlight text after yanking
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  callback = function()
    (vim.hl or vim.highlight).on_yank { timeout = 200 }
  end,
})

-- return to the last cursor position when reopening a file
autocmd("BufReadPost", {
  group = augroup "last_location",
  callback = function(ev)
    local exclude = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close throwaway windows with plain `q`
autocmd("FileType", {
  group = augroup "close_with_q",
  pattern = {
    "help", "lspinfo", "man", "notify", "qf", "query", "startuptime",
    "checkhealth", "neotest-output", "neotest-summary", "neotest-output-panel",
    "dbout", "gitsigns-blame", "copilot-chat",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- wrap + spellcheck in prose buffers
autocmd("FileType", {
  group = augroup "prose",
  pattern = { "markdown", "gitcommit", "text", "plaintex", "typst", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- create missing parent directories on save
autocmd("BufWritePre", {
  group = augroup "auto_create_dir",
  callback = function(ev)
    if ev.match:match "^%w%w+://" then
      return
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- resize splits when the terminal window is resized
autocmd("VimResized", {
  group = augroup "resize_splits",
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- ── dashboard: crash fix + padded selection highlight ────────────────────
-- Two things here.
--
-- 1. nvdash puts the cursor on the first button but never pins it there. A mouse
--    click (mouse is on in Alacritty and tmux) moves it elsewhere; its j/k
--    handler then matches no button, returns nil, and passes that straight to
--    nvim_win_set_cursor:
--        E5108: nvdash/init.lua:214: Expected 2 arguments
--    The four mappings below replace nvdash's with versions that snap to the
--    nearest button instead of erroring.
--
-- 2. The only selection marker nvdash offers is the block cursor, which sits on
--    the icon. Instead we draw a padded highlight behind the whole selected
--    button and hide the cursor while the dashboard is open.
--
-- Note: every nvdash line is EMPTY -- the dashboard is drawn entirely as virtual
-- text -- so buttons are located via extmarks, and the highlight is another
-- extmark layered over the original at a higher priority.
local nvdash_ns = vim.api.nvim_create_namespace "nvdash_selection"
local NVDASH_PAD = 2

local function nvdash_set_hl()
  vim.api.nvim_set_hl(0, "NvDashSelection", { bg = "#313244", fg = "#cdd6f4", bold = true })
end
nvdash_set_hl()
autocmd("ColorScheme", { group = augroup "nvdash_hl", callback = nvdash_set_hl })

--- Locate the dashboard buttons: {line, col, cmd, text, priority} per button.
local function nvdash_buttons(buf)
  local ok, cfg = pcall(require, "nvconfig")
  if not ok or not (cfg.nvdash and cfg.nvdash.buttons) then
    return {}
  end

  local ok2, marks = pcall(vim.api.nvim_buf_get_extmarks, buf, -1, 0, -1, { details = true })
  if not ok2 then
    return {}
  end

  local found, seen = {}, {}
  for _, m in ipairs(marks) do
    local ns, row, details = m[1], m[2], m[4] or {}
    if details.ns_id ~= nvdash_ns then
      local chunks = details.virt_text or {}
      local text = ""
      for _, chunk in ipairs(chunks) do
        text = text .. (chunk[1] or "")
      end

      for _, b in ipairs(cfg.nvdash.buttons) do
        local label = type(b.txt) == "string" and vim.trim(b.txt) or ""
        if label ~= "" and not seen[row] and text:find(label, 1, true) then
          seen[row] = true
          found[#found + 1] = {
            line = row + 1,
            col = details.virt_text_win_col or 0,
            cmd = b.cmd,
            text = text,
            priority = details.priority or 100,
          }
          break
        end
      end
    end
  end

  table.sort(found, function(a, b)
    return a.line < b.line
  end)
  return found
end

--- Draw the padded highlight behind whichever button the cursor is on.
local function nvdash_draw_selection(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, nvdash_ns, 0, -1)

  local cur = vim.api.nvim_win_get_cursor(0)[1]
  for _, b in ipairs(nvdash_buttons(buf)) do
    if b.line == cur then
      local pad = string.rep(" ", NVDASH_PAD)
      pcall(vim.api.nvim_buf_set_extmark, buf, nvdash_ns, b.line - 1, 0, {
        virt_text = { { pad .. b.text .. pad, "NvDashSelection" } },
        virt_text_win_col = math.max(0, b.col - NVDASH_PAD),
        priority = b.priority + 10,
        hl_mode = "combine",
      })
      return
    end
  end
end

--- Move between buttons. delta -1/+1 steps and wraps; 0 only snaps.
local function nvdash_goto(buf, delta, run)
  local buttons = nvdash_buttons(buf)
  if #buttons == 0 then
    return
  end

  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local idx
  for i, b in ipairs(buttons) do
    if b.line == cur then
      idx = i
      break
    end
  end

  if not idx then -- adrift (mouse click): snap, do not also step
    idx = 1
    for i, b in ipairs(buttons) do
      if math.abs(b.line - cur) < math.abs(buttons[idx].line - cur) then
        idx = i
      end
    end
    delta = 0
  end

  local target = buttons[((idx - 1 + delta) % #buttons) + 1]

  if run then
    if target.cmd then
      vim.cmd(target.cmd)
    end
    return
  end

  if not pcall(vim.api.nvim_win_set_cursor, 0, { target.line, target.col }) then
    pcall(vim.api.nvim_win_set_cursor, 0, { target.line, 0 })
  end
  nvdash_draw_selection(buf)
end

-- hide the block cursor while the dashboard is focused, and always restore it
local nvdash_saved_guicursor = nil

local function nvdash_hide_cursor()
  if nvdash_saved_guicursor == nil then
    nvdash_saved_guicursor = vim.o.guicursor
    vim.api.nvim_set_hl(0, "NvDashHiddenCursor", { blend = 100, nocombine = true })
    vim.o.guicursor = "a:NvDashHiddenCursor"
  end
end

local function nvdash_restore_cursor()
  if nvdash_saved_guicursor ~= nil then
    vim.o.guicursor = nvdash_saved_guicursor
    nvdash_saved_guicursor = nil
  end
end

autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "FileType" }, {
  group = augroup "nvdash_cursor",
  callback = function()
    if vim.bo.filetype == "nvdash" then
      nvdash_hide_cursor()
    else
      nvdash_restore_cursor()
    end
  end,
})

autocmd("VimLeave", { group = augroup "nvdash_cursor_restore", callback = nvdash_restore_cursor })

autocmd("FileType", {
  group = augroup "nvdash_fix",
  pattern = "nvdash",
  callback = function(ev)
    local function map(lhs, delta, run)
      vim.keymap.set("n", lhs, function()
        nvdash_goto(ev.buf, delta, run)
      end, { buffer = ev.buf, silent = true, nowait = true })
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then
        return
      end
      map("j", 1, false)
      map("<down>", 1, false)
      map("k", -1, false)
      map("<up>", -1, false)
      map("<cr>", 0, true)

      -- This whole block patches NvChad internals (extmark rendering, the
      -- nvconfig.nvdash.buttons shape, labels appearing verbatim in virt_text,
      -- and nvdash installing its mappings before this vim.schedule runs).
      -- NvChad tracks the moving v2.5 branch, so those assumptions will break
      -- eventually. Say so loudly -- silently returning {} would restore the
      -- E5108 crash with nothing pointing here.
      if #nvdash_buttons(ev.buf) == 0 and not vim.g.nvdash_patch_warned then
        vim.g.nvdash_patch_warned = true
        vim.notify(
          "nvdash patch in autocmds.lua found no buttons -- NvChad's dashboard "
            .. "internals likely changed. j/k may error again (E5108). See the "
            .. "nvdash_fix block.",
          vim.log.levels.WARN
        )
      end

      nvdash_draw_selection(ev.buf)

      autocmd("CursorMoved", {
        buffer = ev.buf,
        callback = function()
          nvdash_goto(ev.buf, 0, false)
        end,
      })
    end)
  end,
})
