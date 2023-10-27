return {
  "mfussenegger/nvim-dap",
  dependencies = {
    { "rcarriga/nvim-dap-ui" },
    { "theHamsta/nvim-dap-virtual-text", config = true },
    {
      "microsoft/vscode-js-debug",
      version = "1.x",
      build = "rm -rf out && npm ci && npm run compile vsDebugServerBundle && mv dist out",
    },
    -- {
    --   "ibhagwan/fzf-lua",
    -- },
  },
  config = function()
    local dap = require "dap"
    local debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug"
    local log_file_path = vim.fn.stdpath "cache" .. "/dap_vscode_js.log"

    require("dap-vscode-js").setup {
      node_path = os.getenv "NODE_PATH" or "node",
      debugger_path = debugger_path,
      adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      log_file_path = log_file_path,
      log_console_level = vim.log.levels.INFO,
      log_file_level = vim.log.levels.INFO,
    }

    -- local firefox_adapter_path = vim.fn.stdpath "data" .. "/mason/packages/firefox-debug-adapter/dist/adapter.bundle.js"
    dap.adapters.firefox = {
      type = "executable",
      command = "firefox-debug-adapter",
      enrich_config = function(config, on_config)
        config = config or {}
        on_config(config)
      end,
    }

    local js_based_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact", "svelte" }

    local firefox_executable_path = "/Applications/Firefox.app/Contents/MacOS/firefox"
    for _, language in ipairs(js_based_languages) do
      dap.configurations[language] = {
        {
          name = "Debug Vite with Firefox",
          type = "firefox",
          request = "launch",
          reAttach = true,
          url = "http://localhost:5173",
          webRoot = "${workspaceFolder}/src",
          skipFiles = {
            "<node_internals>/**",
            "node_modules/**",
          },
          firefoxExecutable = firefox_executable_path,
        },
        {
          name = "Debug Vite with Edge",
          type = "pwa-msedge",
          request = "attach",
          sourceMaps = true,
          program = "${file}",
          cwd = vim.fn.getcwd(),
          url = "http://localhost:5173",
          protocol = "inspector",
          port = 9222,
          webRoot = "${workspaceFolder}/src",
          skipFiles = {
            "<node_internals>/**",
            "node_modules/**",
          },
        },
        {
          name = "Debug Vite with Chrome",
          type = "pwa-chrome",
          request = "attach",
          sourceMaps = true,
          url = "http://localhost:5173",
          protocol = "inspector",
          port = 9222,
          webRoot = "${workspaceFolder}/src",
        },
      }
    end

    local coreclr_adapter_path = os.getenv "HOME" .. "/.local/netcoredbg/build/src/netcoredbg"
    dap.adapters.coreclr = {
      type = "executable",
      command = coreclr_adapter_path,
      args = { "--interpreter=vscode" },
      enrich_config = function() end,
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Attach to running process",
        request = "attach",
        processId = function() return require("dap.utils").pick_process() end,
      },
      {
        type = "coreclr",
        name = "Launch .net core",
        request = "launch",
        program = function()
          local function get_file_sync()
            local co = coroutine.running()
            local selected_file = nil
            local files = { "a", "b", "c" } -- vim.fn.glob(vim.fn.getcwd() .. "/**/bin/Debug/**/*.dll", true, true)
            vim.ui.select(files, {
              prompt = "Select dll to debug >",
            }, function(text)
              selected_file = "file://" .. text
              vim.print("Selected file: " .. selected_file)
              coroutine.resume(co)
            end)

            coroutine.yield()
            return selected_file
          end
          local file = get_file_sync()
          return file
        end,
      },
    }

    require("dap.ext.vscode").load_launchjs(nil, {
      ["node"] = js_based_languages,
      ["node-terminal"] = js_based_languages,
      ["extensionHost"] = js_based_languages,
      ["chrome"] = js_based_languages,
      ["msedge"] = js_based_languages,
      ["pwa-msedge"] = js_based_languages,
      ["firefox"] = js_based_languages,
      ["coreclr"] = { "cs" },
    })
  end,
}
