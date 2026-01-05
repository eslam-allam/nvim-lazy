return {
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    event = "LspAttach",
    opts = {
      picker = { "buffer", opts = {
        hotkeys = false,
      } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "rachartier/tiny-code-action.nvim" },
    opts = {
      servers = {
        ["*"] = {
          keys = {
            {
              "<leader>ca",
              function()
                require("tiny-code-action").code_action()
              end,
              desc = "Code Actions",
            },
          },
        },
      },
    },
  },
}
