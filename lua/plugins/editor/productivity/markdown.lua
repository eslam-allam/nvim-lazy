return {
  {
    "SCJangra/table-nvim",
    ft = "markdown",
    opts = {},
  },
  {
    "epilande/checkbox-cycle.nvim",
    ft = "markdown",
    opts = {
      states = { "[ ]", "[x]" },
    },
    keys = {
      {
        "<CR>",
        "<Cmd>CheckboxCycleNext<CR>",
        desc = "Checkbox Next",
        ft = { "markdown" },
        mode = { "n", "v" },
      },
    },
  },
}
