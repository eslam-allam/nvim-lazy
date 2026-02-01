return {
  {
    "supermaven-inc/supermaven-nvim",
    optional = true,
    dependencies = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = {
          sources = {
            providers = {
              supermaven = {
                kind = "Supermaven",
                score_offset = 100,
                async = true,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      local color = require("catppuccin.palettes").get_palette("mocha").blue
      if vim.g.color_scheme == "matugen" then
        color = require("base16-colorscheme").colors.base08
      end

      require("modules.completion-styler").addIcon("Supermaven", "󱚟")
      vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = color })
      require("supermaven-nvim").setup(opts)
    end,
  },
}
