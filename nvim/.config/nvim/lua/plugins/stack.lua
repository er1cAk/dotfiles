-- Plugins picked for the actual stack:
-- Go, Python (uv), TS/JS, Angular/React/Next, Postgres/SQLite, Markdown.
return {
  -- ── database client ─────────────────────────────────────────────────────
  -- postgres is referenced in 120 repos here, sqlite in 9, drizzle in 14, and
  -- psql/sqlite3/mysql clients are all already installed.
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath "data" .. "/db_ui"
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      -- keep the drawer out of the way of nvim-tree
      vim.g.db_ui_winwidth = 34
    end,
  },

  -- SQL completion (tables/columns) inside sql buffers
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        group = vim.api.nvim_create_augroup("erik_dadbod_cmp", { clear = true }),
        callback = function()
          local ok, cmp = pcall(require, "cmp")
          if not ok then
            return
          end
          cmp.setup.buffer {
            sources = cmp.config.sources {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          }
        end,
      })
      return opts
    end,
  },

  -- ── python: pick the interpreter uv created ─────────────────────────────
  -- uv puts its environment at .venv in the project root. Without selecting it,
  -- basedpyright resolves imports against whatever interpreter it finds first
  -- and reports third-party imports as unresolved.
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    ft = "python",
    cmd = { "VenvSelect", "VenvSelectCached" },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
        search = {
          -- uv (and most tooling) put the env at <project>/.venv
          project_venv = {
            command = "fd '^python$' $CWD/.venv/bin --full-path --color never -E /proc",
          },
          workspace_venv = {
            command = "fd '^python$' $WORKSPACE_PATH/.venv/bin --full-path --color never -E /proc",
          },
        },
      },
    },
    config = function(_, opts)
      require("venv-selector").setup(opts)

      -- Auto-activate the project's uv environment. Without this, basedpyright
      -- resolves imports against whichever interpreter it finds first and marks
      -- third-party imports unresolved until you run :VenvSelect by hand.
      local function activate_project_venv()
        local vs = require "venv-selector"
        local current = vs.venv()
        if current and current ~= "" then
          return -- already on a venv; don't override a manual choice
        end

        local root = vim.fs.root(0, { ".venv", "uv.lock", "pyproject.toml", ".git" })
        if not root then
          return
        end

        local python = root .. "/.venv/bin/python"
        if vim.uv.fs_stat(python) then
          pcall(vs.activate_from_path, python)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        group = vim.api.nvim_create_augroup("erik_venv_auto", { clear = true }),
        callback = function()
          vim.defer_fn(activate_project_venv, 100)
        end,
      })

      -- this plugin loads on the first python file, so that FileType already fired
      vim.defer_fn(activate_project_venv, 200)
    end,
  },

  -- ── markdown ────────────────────────────────────────────────────────────
  -- Alacritty cannot draw inline images (no sixel, no kitty graphics protocol),
  -- so images stay a browser concern -- markdown-preview.nvim handles those and
  -- mermaid. This makes the buffer itself readable.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "codecompanion", "copilot-chat" },
    opts = {
      code = { sign = false, width = "block", right_pad = 1 },
      heading = { sign = false, icons = {} },
      checkbox = { enabled = true },
    },
  },

  -- ── package.json dependency versions ────────────────────────────────────
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = { "BufRead package.json" },
    opts = {
      hide_up_to_date = false,
      package_manager = "pnpm",
    },
    config = function(_, opts)
      require("package-info").setup(opts)

      -- Buffer-local on purpose: <leader>n is NvChad's line-number toggle, so a
      -- global <leader>n* group would make every press of it wait out timeoutlen.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("erik_package_info", { clear = true }),
        pattern = "package.json",
        callback = function(ev)
          local pi = require "package-info"
          local function map(lhs, fn, desc)
            vim.keymap.set("n", lhs, fn, { buffer = ev.buf, silent = true, desc = desc })
          end
          map("<leader>ns", pi.show, "package: show versions")
          map("<leader>nh", pi.hide, "package: hide versions")
          map("<leader>nu", pi.update, "package: update dependency")
          map("<leader>nd", pi.delete, "package: delete dependency")
          map("<leader>ni", pi.install, "package: install new dependency")
          map("<leader>nc", pi.change_version, "package: change version")
        end,
      })
    end,
  },
}
