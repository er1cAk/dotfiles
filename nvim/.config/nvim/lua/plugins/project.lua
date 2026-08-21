return {
  -- ── project detection + recent projects list ────────────────────────────
  -- Same plugin LazyVim's `util.project` extra used, so the behaviour should
  -- feel familiar: roots are detected from LSP and from marker files, and the
  -- most recently opened ones are kept in a list.
  {
    "ahmedkhalf/project.nvim",
    -- Loaded eagerly: its history read is async, and the dashboard's "Recent
    -- Projects" button is reachable the instant nvim opens. On VeryLazy the
    -- list is still empty at that point.
    lazy = false,
    priority = 100,
    config = function()
      require("project_nvim").setup {
        -- "pattern" only, deliberately: the "lsp" method calls the removed
        -- vim.lsp.buf_get_clients(), which prints a deprecation warning on
        -- every startup under Neovim 0.12. All your repos are git repos, so
        -- pattern matching finds them anyway.
        detection_methods = { "pattern" },
        patterns = {
          ".git", "_darcs", ".hg", ".bzr", ".svn",
          "Makefile", "package.json", "go.mod", "pyproject.toml",
          "Cargo.toml", "composer.json", "pom.xml", "build.gradle",
          ".terraform", "docker-compose.yml",
        },
        -- don't chdir automatically; the dashboard buttons do it explicitly
        manual_mode = false,
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
      }
      pcall(function()
        require("telescope").load_extension "projects"
      end)
    end,
  },
}
