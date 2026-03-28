return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    }
  },
  {
    "LazyVim/LazyVim",
    dependencies = {
      {
        "GnRlLeclerc/dynamic-base16.nvim",
        config = function()
          require("dynamic-base16").setup()
        end,
      },
    },
    lazy = false,
    priotity = 1000,
    opts = {
      colorscheme = function()
        if vim.g.auto_color_scheme then
          local ok, matugen = pcall(require, "matugen")
          if ok then
            ok, matugen = pcall(matugen.setup)
            if ok then
              vim.g.color_scheme = "dynamic-base16"
              return
            else
              vim.notify_once("[LazyVim] Error setting up matugen:" .. matugen, vim.log.levels.WARN)
            end
          end
        end

        vim.g.color_scheme = "tokyonight-night"
        vim.cmd.colorscheme("tokyonight-night")
      end,
    },
  },
}
