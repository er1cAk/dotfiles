-- Neovim 0.11 native LSP config on top of NvChad's defaults.
require("nvchad.configs.lspconfig").defaults()

-- Make sure mason-installed binaries are on PATH before we probe for them.
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
if not string.find(vim.env.PATH or "", mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
end

-- server name -> executable that must exist for it to be worth enabling
local servers = {
  -- lua
  lua_ls = "lua-language-server",

  -- web / js / ts
  ts_ls = "typescript-language-server",
  eslint = "vscode-eslint-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  jsonls = "vscode-json-language-server",
  emmet_language_server = "emmet-language-server",
  tailwindcss = "tailwindcss-language-server",
  angularls = "ngserver",

  -- go
  gopls = "gopls",

  -- python
  basedpyright = "basedpyright",
  ruff = "ruff",

  -- data / config / docs
  yamlls = "yaml-language-server",
  taplo = "taplo",
  marksman = "marksman",

  -- infra
  bashls = "bash-language-server",
  dockerls = "docker-langserver",
  docker_compose_language_service = "docker-compose-langserver",
  terraformls = "terraform-ls",
  helm_ls = "helm_ls",

  -- php: CloudTalk-era legacy API still has real source here
  intelephense = "intelephense",
}

-- ── per-server overrides ──────────────────────────────────────────────────

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        useany = true,
        nilness = true,
        shadow = false,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      codelenses = { gc_details = true, generate = true, test = true, tidy = true },
    },
  },
})

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

-- ruff handles lint + format; let basedpyright own hover
vim.lsp.config("ruff", {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literal",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },
  },
})

-- schemastore is optional; fall back cleanly if it is not installed yet
local function schemas(kind)
  local ok, ss = pcall(require, "schemastore")
  if not ok then
    return nil
  end
  return ss[kind].schemas()
end

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      keyOrdering = false,
      validate = true,
      -- schemastore plugin supplies the catalog, so disable the built-in one
      schemaStore = { enable = false, url = "" },
      schemas = schemas "yaml",
    },
  },
})

vim.lsp.config("jsonls", {
  settings = {
    json = {
      validate = { enable = true },
      schemas = schemas "json",
    },
  },
})

-- ── enable only what is actually installed ────────────────────────────────
local enabled = {}
for server, bin in pairs(servers) do
  if vim.fn.executable(bin) == 1 then
    table.insert(enabled, server)
  end
end
vim.lsp.enable(enabled)

-- ── diagnostics: LazyVim-ish presentation ─────────────────────────────────
vim.diagnostic.config {
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
}
