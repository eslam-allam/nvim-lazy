return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ols = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "odin"
      },
    },
  },
}
