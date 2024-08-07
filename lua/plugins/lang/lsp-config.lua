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

      opts.setup.jsonls = function(_, sopts)
        sopts.settings = {
          json = {
            schemas = {
              {
                description = "Custom schema for neovim jdtls runtimes",
                name = "java-runtimes.json",
                fileMatch = { "java-runtimes.json" },
                url = "file://" .. vim.env.JAVA_RUNTIMES_JSON_SCHEMA,
              },
              {
                description = "Custom schema for google-java-format",
                name = "Google Java Format config",
                fileMatch = { "google-java-format.json", ".google-java-format.json" },
                url = "file://" .. vim.env.FORMATTER_SCHEMA_DIR .. "/google-java-format.schema.json",
              },
            },
            validate = { enable = true },
          },
        }
      end
    end,
  },
}
