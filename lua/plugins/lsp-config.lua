return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        gradle_ls = {},
      },
      setup = {
        gradle_ls = function(_, opts)
          opts.root_dir = require("modules.java").javaRoot
        end,
      },
    },
  },
}
