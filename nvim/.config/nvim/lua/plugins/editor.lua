return {
  -- ── jump anywhere with `s` (LazyVim default motion) ─────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { jump_labels = true } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    },
  },

  -- ── diagnostics / quickfix list (LazyVim <leader>x*) ────────────────────
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { focus = true },
  },

  -- ── TODO / FIXME highlighting + search ──────────────────────────────────
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "TodoTrouble", "TodoTelescope" },
    opts = {},
  },

  -- ── session persistence (LazyVim <leader>qs / qS / ql) ──────────────────
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- ── lazygit inside nvim (you already have lazygit installed) ────────────
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- ── git blame / diff view ───────────────────────────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {},
  },

  -- ── carried over from your LazyVim config ───────────────────────────────
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  {
    "gangleri/vim-diffsaved",
    cmd = { "DiffSaved" },
    event = "BufReadPost",
  },

  -- ── surround / extra text objects (LazyVim has these via mini) ──────────
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    -- gs* prefix, not mini's default s*: `s` is mapped to Flash, and mini's
    -- defaults (sa/sd/sr/sf/sh) make `s` a prefix too, so every Flash jump
    -- waited out timeoutlen. This is also the prefix LazyVim uses.
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        replace = "gsr",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        update_n_lines = "gsn",
        suffix_last = "l",
        suffix_next = "n",
      },
    },
  },

  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {},
  },
}
