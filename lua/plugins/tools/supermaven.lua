return {
  {
    "supermaven-inc/supermaven-nvim",
    dependencies = {
      {
        "nvim-cmp",
        opts = function(_, opts)
          require("modules.completion-styler").addIcon("Supermaven", "󱚟")
          table.insert(opts.sources, { name = "supermaven" })
          local colors = require("catppuccin.palettes").get_palette("mocha")
          vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = colors.blue })
        end,
      },
    },
    config = true,
    opts = {
      disable_keymaps = true,
      disable_inline_completion = true,
    },
  },
}
