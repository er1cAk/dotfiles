return {
  -- ── GitHub Copilot (you were already authenticated: ~/.config/github-copilot) ──
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      -- suggestions come through the completion menu (copilot-cmp), like LazyVim
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
        gitcommit = true,
        yaml = true,
        ["*"] = true,
      },
    },
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- register copilot as the top-priority nvim-cmp source
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "zbirenbaum/copilot-cmp" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "copilot", group_index = 1, priority = 100 })
      return opts
    end,
  },

  -- ── Copilot Chat ────────────────────────────────────────────────────────
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = { "CopilotChat", "CopilotChatToggle", "CopilotChatOpen", "CopilotChatExplain", "CopilotChatReview", "CopilotChatFix", "CopilotChatOptimize", "CopilotChatTests", "CopilotChatCommit" },
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      model = "claude-sonnet-4.5",
      window = { layout = "vertical", width = 0.35 },
    },
  },
}
