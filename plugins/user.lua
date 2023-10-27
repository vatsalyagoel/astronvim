return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
  {
    "microsoft/vscode-js-debug",
    build = "npm ci && npm run compile vsDebugServerBundle && mv dist out",
  },
  {
    "mxsdev/nvim-dap-vscode-js",
  },
  {
    "Joakker/lua-json5",
    build = "./install.sh",
    config = function() table.insert(vim.so_trails, "/?.dylib") end,
  },
  {
    "b0o/SchemaStore.nvim",
    config = function()
      local lspConfig = require "lspconfig"
      local schemastore = require "schemastore"
      lspConfig.jsonls.setup {
        settings = {
          json = {
            schemas = schemastore.json.schemas(),
            validate = { enable = true },
          },
        },
      }
    end,
  },
  -- {
  --   "ibhagwan/fzf-lua",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   config = function()
  --     local fzf = require "fzf-lua"
  --
  --     fzf.register_ui_select(function(_, items)
  --       -- Auto-height
  --       local min_h, max_h = 0.15, 0.70
  --       local h = (#items + 2) / vim.o.lines
  --       if h < min_h then
  --         h = min_h
  --       elseif h > max_h then
  --         h = max_h
  --       end
  --
  --       -- Auto-width
  --       -- if (#items < 10000) then	-- Maybe disable auto-width on large results?
  --       local min_w, max_w = 0.05, 0.70
  --       local longest = 0
  --       for _, v in ipairs(items) do
  --         local length = #v
  --         if length > longest then longest = length end
  --       end
  --
  --       -- needs minimum 7 in my case due to the extra stuff fzf adds on the left side (markers, numbers, extra padding, etc).
  --       local w = (longest + 9) / vim.o.columns
  --       if w < min_w then
  --         w = min_w
  --       elseif w > max_w then
  --         w = max_w
  --       end
  --       -- end
  --
  --       return {
  --         winopts = {
  --           height = h,
  --           width = w,
  --           row = 0.5,
  --           col = 0.5,
  --         },
  --         fzf_opts = {
  --           ["--layout"] = "reverse-list",
  --           ["--info"] = "hidden",
  --         },
  --       }
  --     end)
  --   end,
  -- },
}
