return {
  -- ── formatting ──────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = require "configs.conform",
  },

  -- ── LSP ─────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "b0o/schemastore.nvim" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  { "b0o/schemastore.nvim", lazy = true },

  -- ── mason: auto-install the toolchain ───────────────────────────────────
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        -- language servers (core set)
        "lua-language-server",
        "typescript-language-server",
        "eslint-lsp",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "emmet-language-server",
        "tailwindcss-language-server",
        "gopls",
        "basedpyright",
        { "ruff", version = "0.16.3" },
        "yaml-language-server",
        "taplo",
        "marksman",
        "bash-language-server",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "terraform-ls",
        "prisma-language-server",

        -- Formatters are PINNED: they rewrite file contents, so a version
        -- difference between machines shows up as spurious diffs in PRs.
        -- Language servers deliberately float -- they only affect diagnostics.
        -- formatters
        { "stylua", version = "v2.5.2" },
        { "prettierd", version = "0.29.0" },
        { "goimports", version = "v0.49.0" },
        { "shfmt", version = "v3.13.1" },
        { "sql-formatter", version = "15.8.2" },

        -- debug adapters
        "delve",
        "js-debug-adapter",
        "debugpy",
      },
      run_on_start = true,
      start_delay = 3000,
      auto_update = false,
      debounce_hours = 24,
    },
  },

  -- ── treesitter ──────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "luadoc", "vim", "vimdoc", "query",
        "bash", "c", "diff", "regex", "printf",
        "html", "css", "scss", "javascript", "typescript", "tsx", "vue", "svelte",
        "json", "yaml", "toml", "xml",
        "markdown", "markdown_inline",
        "go", "gomod", "gosum", "gowork",
        "python",
        "java", "kotlin", "php",
        "dockerfile", "terraform", "hcl",
        "sql", "prisma", "graphql",
        "cmake", "make", "ninja",
        "git_config", "gitcommit", "gitignore", "git_rebase",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3, multiline_threshold = 1 },
  },

  -- ── file tree (carried-over LazyVim/neo-tree preferences) ───────────────
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      git = { enable = true, ignore = true },
      filters = {
        dotfiles = false,
        git_ignored = true,
        custom = { "^\\.DS_Store$", "^\\.git$", "^\\.idea$", "^\\.vscode$", "^node_modules$" },
      },
      view = { width = 34, preserve_window_proportions = true },
      renderer = {
        highlight_git = true,
        highlight_opened_files = "name",
        indent_markers = { enable = true },
      },
      actions = { open_file = { quit_on_open = false, window_picker = { enable = true } } },
    },
  },

  -- ── telescope ───────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        path_display = { "truncate" },
        layout_config = { horizontal = { preview_width = 0.55 } },
        file_ignore_patterns = { "node_modules", "%.git/", "dist/", "build/", "%.lock" },
      },
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { "--hidden" } },
      },
    },
  },

  -- ── indent guides on scope (LazyVim look) ───────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = { scope = { enabled = true, show_start = false, show_end = false } },
  },
}
