return {
  {
    "supermaven-inc/supermaven-nvim",
    config = function(_, opts)
      require("modules.completion-styler").addIcon("Supermaven", "󱚟")
      local colors = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = colors.blue })
      require("supermaven-nvim").setup(opts)
    end,
  },
}
