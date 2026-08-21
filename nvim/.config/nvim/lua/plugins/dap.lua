return {
  -- ── debugging: go (delve), python (debugpy), js/ts (js-debug) ──────────
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver", "DapStepInto", "DapStepOut" },
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require "dap", require "dapui"
          dapui.setup()
          dap.listeners.before.attach.dapui_config = function() dapui.open() end
          dap.listeners.before.launch.dapui_config = function() dapui.open() end
          dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
          dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      {
        "leoluz/nvim-dap-go",
        ft = "go",
        opts = {},
      },
      {
        -- Maps Mason packages to dap adapters + default configurations upstream.
        -- This is what LazyVim's dap.core extra uses. Without it, js-debug-adapter
        -- and debugpy sit installed but unregistered, and the whole <leader>d*
        -- group silently does nothing outside Go and Lua.
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          ensure_installed = { "js", "python" },
          automatic_installation = false,
          handlers = {}, -- empty = use the default handler for every source
        },
      },
    },
    config = function()
      local dap = require "dap"

      -- breakpoint signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      -- ── JS / TS via js-debug-adapter ──────────────────────────────────
      -- mason-nvim-dap knows the package name but ships no adapter definition
      -- for it (it covers bash/chrome/delve/python/... but not js), so the
      -- adapter has to be registered by hand or the whole <leader>d* group is
      -- dead in JS/TS files.
      local js_debug = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter"
      local js_entry = js_debug .. "/js-debug/src/dapDebugServer.js"

      if vim.uv.fs_stat(js_entry) then
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { js_entry, "${port}" },
          },
        }

        for _, ft in ipairs { "javascript", "typescript", "javascriptreact", "typescriptreact" } do
          dap.configurations[ft] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch current file",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              protocol = "inspector",
              skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to process",
              processId = function()
                return require("dap.utils").pick_process()
              end,
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
          }
        end
      end
    end,
  },
}
