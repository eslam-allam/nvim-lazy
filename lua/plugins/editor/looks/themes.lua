return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
    },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    priotity = 1000,
    opts = function(_, opts)
      local colors = require("catppuccin.palettes").get_palette("mocha")
      local localOpts = {
        custom_highlights = {
          TelescopeMatching = { fg = colors.flamingo },
          TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

          TelescopePromptPrefix = { bg = colors.surface0 },
          TelescopePromptNormal = { bg = colors.surface0 },
          TelescopeResultsNormal = { bg = colors.mantle },
          TelescopePreviewNormal = { bg = colors.mantle },
          TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
          TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
          TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
          TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
          TelescopeResultsTitle = { fg = colors.mantle },
          TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
        },
      }
      return vim.tbl_extend("force", opts, localOpts)
    end,
  },
  {
    "LazyVim/LazyVim",
    lazy = false,
    priotity = 1000,
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
