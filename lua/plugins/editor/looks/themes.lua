return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    dependencies = {
      {
        "daedlock/matugen.nvim",
        lazy = false,
        priority = 1000,
        config = true,
        opts = {
          colors_path = require("plenary.path")
            :new(vim.fn.stdpath("config"))
            :joinpath("lua", "matugen.json")
            :absolute(),
        },
      },
    },
    lazy = false,
    priotity = 1000,
    opts = {
      colorscheme = function()
        if vim.g.auto_color_scheme then
          vim.g.color_scheme = "matugen"
          vim.cmd.colorscheme("matugen")
          return
        end

        vim.g.color_scheme = "tokyonight-night"
        vim.cmd.colorscheme("tokyonight-night")
      end,
    },
  },
}
