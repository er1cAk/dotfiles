return {
  -- ── neotest (carried over: jest + vitest adapters) ──────────────────────
  {
    "nvim-neotest/neotest",
    cmd = "Neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-jest",
          require "neotest-vitest",
          require "neotest-go",
          require "neotest-python",
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
      }
    end,
  },
}
