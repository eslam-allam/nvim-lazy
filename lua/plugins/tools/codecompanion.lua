return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
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
    {
      "saghen/blink.cmp",
      optional = true,
      opts = function(_, opts)
        table.insert(opts.sources.default, "codecompanion")
        opts.sources.providers.codecompanion = {
          name = "CodeCompanion",
          module = "codecompanion.providers.completion.blink",
        }
      end,
    },
    { "MeanderingProgrammer/render-markdown.nvim", optional = true, ft = { "codecompanion" } },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)
    require("which-key").add({
      "<leader>cg",
      group = "CodeCompanion",
      icon = { icon = "󰁤", color = "green" },
      mode = { "n", "v" },
      { "<leader>cgc", "<cmd>CodeCompanionChat<CR>", desc = "Chat" },
      { "<leader>cga", "<cmd>CodeCompanionActions<CR>", desc = "Display Actions" },
      { "<leader>cgt", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle Chat" },
      { "ga", "<cmd>CodeCompanionAdd<CR>", desc = "Add code", mode = "v" },
      {
        "<leader>cgA",
        desc = "Quick Actions",
        { "<leader>cgAe", "<cmd>CodeCompanion /explain<CR>", desc = "Explain Code", mode = "v" },
        { "<leader>cgAE", "<cmd>CodeCompanion /lsp<CR>", desc = "Explain Code Using LSP", mode = "v" },
        { "<leader>cgAf", "<cmd>CodeCompanion /fix<CR>", desc = "Fix Code", mode = "v" },
        { "<leader>cgAc", "<cmd>CodeCompanion /commit<CR>", desc = "Generate Commit" },
      },
    })
  end,
  opts = {
    display = {
      diff = {
        provider = "mini_diff",
      },
    },
    log_level = "TRACE",
    strategies = {
      chat = {
        adapter = {
          name = "openai",
          model = "gpt-5.1",
        },
      },
      inline = {
        adapter = {
          name = "openai",
        },
        keymaps = {
          accept_change = {
            modes = { n = "gca" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "gcr" },
            description = "Reject the suggested change",
          },
        },
      },
      agent = {
        adapter = {
          name = "openai",
        },
      },
    },
    adapters = {
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = "cmd:rbw get 'OpenAI Neovim'",
          },
        })
      end,
    },
  },
}
