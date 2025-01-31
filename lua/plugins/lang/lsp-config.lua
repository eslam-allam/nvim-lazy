return {
  {
    "mosheavni/yaml-companion.nvim",
    ft = "yaml",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      local cfg = require("yaml-companion").setup({})
      require("lspconfig")["yamlls"].setup(cfg)
      require("telescope").load_extension("yaml_schema")
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "<leader>ys",
        function () require("yaml-companion").open_ui_select() end,
        desc = "Yaml Schema",
      }
    end,
  },
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

      local mason_home = vim.fn.getenv("MASON")

      -- make sure mason installs the server
      opts.servers.gradle_ls = {}
      opts.setup.gradle_ls = function(_, sopts)
        sopts.cmd = {
          require("modules.java").execAtleast(17),
          "-jar",
          mason_home .. "/packages/gradle-language-server/extension/lib/gradle-language-server.jar",
        }
        sopts.root_dir = require("modules.java").javaRoot
      end

      opts.setup.tailwindcss = function(_, sopts)
        sopts.settings = {
          tailwindCSS = {
            includeLanguages = { templ = "html" },
            experimental = {
              classRegex = {
                "[a-zA-Z]*Class='([^']+)'",
                '[a-zA-Z]*Class="([^"]+)"',
                "[a-zA-Z]*Class={`([^`]+)`}",
                "(?:[a-zA-Z]\\.)+class\\s*=\\s*'([^']+)'",
                "[a-zA-Z]*ClassName='([^']+)'",
                '[a-zA-Z]*ClassName="([^"]+)"',
                "[a-zA-Z]*ClassName={`([^`]+)`}",
                "(?:[a-zA-Z]\\.)+className\\s*=\\s*'([^']+)'",
              },
            },
          },
        }
      end
      local new_ft = {}
      for _, value in ipairs(require("lspconfig.configs.tailwindcss").default_config.filetypes) do
        if value ~= "markdown" then
          table.insert(new_ft, value)
        end
      end
      opts.servers.tailwindcss.filetypes = new_ft

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
