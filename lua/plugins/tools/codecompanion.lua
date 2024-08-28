return {
  "olimorris/codecompanion.nvim",
  lazy = true,
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionToggle", "CodeCompanionActions", "CodeCompanionAdd" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- Optional
    {
      "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
      opts = {},
    },
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        table.insert(opts.sections.lualine_x, 1, require("modules.codecompanion-status"))
      end,
    },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)
  end,
  opts = {
    log_level = "TRACE",
    strategies = {
      chat = {
        adapter = "llama_remote",
      },
      inline = {
        adapter = "llama_remote",
      },
      agent = {
        adapter = "llama_remote",
      },
    },
    adapters = {

      llama_remote = function()

        local home = vim.fn.getenv("HOME")
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama_remote", -- Ensure the model is differentiated from Ollama
          env = {
            url = "https://adriai.org/ollama/backend",
            api_key = "cmd:gpg --decrypt " .. home .. "/.secrets/adri-ollama-secret.gpg 2>/dev/null",
          },
          headers = {
            ["Content-Type"] = "application/json",
            ["CF-Access-Client-Id"] = "2b2c5857211179d8dcee2e65d9d0dffd.access",
            ["CF-Access-Client-Secret"] = "${api_key}",
          },
          schema = {
            model = {
              default = "llama3.1:8b",
            },
          },
        })
      end,
      wizardcoder = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "wizardcoder", -- Ensure the model is differentiated from Ollama
          schema = {
            model = {
              default = "wizardcoder:python",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
          },
        })
      end,
      deepseek_v2 = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "deepseek-v2", -- Ensure the model is differentiated from Ollama
          schema = {
            model = {
              default = "deepseek-coder-v2",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
          },
        })
      end,
    },
  },
}
