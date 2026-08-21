local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    -- web / js ecosystem
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    vue = { "prettierd", "prettier", stop_after_first = true },
    svelte = { "prettierd", "prettier", stop_after_first = true },
    astro = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    less = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    graphql = { "prettierd", "prettier", stop_after_first = true },

    -- go
    -- gofmt, not gofumpt: CloudTalk's .golangci.yml enables gofmt + goimports.
    -- gofumpt is stricter, so it silently reformats beyond what those repos
    -- expect and adds unrelated noise to PRs.
    go = { "goimports", "gofmt" },

    -- python
    python = { "ruff_organize_imports", "ruff_format" },

    -- shell / infra
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    terraform = { "terraform_fmt" },
    tf = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    hcl = { "terraform_fmt" },
    toml = { "taplo" },
    sql = { "sql_formatter" },
  },

  -- LazyVim formats on save; keep that habit.
  format_on_save = function(bufnr)
    -- respect a per-buffer / global escape hatch: :FormatDisable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 1000, lsp_fallback = true }
  end,

  formatters = {
    shfmt = { prepend_args = { "-i", "2", "-ci" } },
  },
}

return options
