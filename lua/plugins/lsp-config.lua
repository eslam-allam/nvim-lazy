return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local helpers = require("modules.helpers")
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "K",
        function()
          helpers.lspRequestExcludeLsps(vim.lsp.protocol.Methods.textDocument_hover, vim.g.hover_exclude_lsps)
        end,
      }
      keys[#keys + 1] = {
        "gd",
        function()
          helpers.lspRequestExcludeLsps(vim.lsp.protocol.Methods.textDocument_definition, vim.g.definition_exclude_lsps)
        end,
      }
      -- make sure mason installs the server
      opts.servers.gradle_ls = {}
      opts.setup.gradle_ls = function(_, sopts)
        sopts.root_dir = require("modules.java").javaRoot
      end
      opts.setup.tailwindcss = function(_, sopts)
        sopts.settings = {
          tailwindCSS = {
            includeLanguages = { templ = "html" },
          },
        }
      end
    end,
  },
}
