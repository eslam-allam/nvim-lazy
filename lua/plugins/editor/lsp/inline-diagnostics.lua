return {
  "rachartier/tiny-inline-diagnostic.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  event = "VeryLazy",
  opts = {
    options = {
      overflow = {
        mode = "wrap",
      },
    },
  },
  config = function(_, opts)
    vim.diagnostic.config({ virtual_text = false, underline = true })
    require("tiny-inline-diagnostic").setup(opts)
  end,
}
