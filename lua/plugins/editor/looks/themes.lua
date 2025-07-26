return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
    lazy = false,
    priotity = 1000,
    opts = function(_, opts)
      local localOpts = {
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          snacks = {
            enabled = true,
            picker_style = "classic",
          },
          mason = true,
          harpoon = true,
          treesitter = true,
          notify = true,
          diffview = true,
          gitsigns = {
            enabled = true,
            transparent = true,
          },
          grug_far = true,
          leap = true,
          noice = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
              ok = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
              ok = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          octo = true,
          which_key = true,
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
      colorscheme = "catppuccin",
    },
  },
}
