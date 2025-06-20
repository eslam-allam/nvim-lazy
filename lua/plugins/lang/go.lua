return {
  {
    "maxandron/goplements.nvim",
    ft = "go",
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.htmx = {
        mason = false,
      }
    end,
  },
}
