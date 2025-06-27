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

      -- Enable completion in wire template file
      opts.setup.gopls = function(_, sopts)
        sopts.settings = {
          gopls = {
            buildFlags = { "-tags=wireinject" },
          },
        }
      end
    end,
  },
}
