return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches" },
  },
  opts = {

    extensions = {
      project = {
        base_dirs = {
          "~",
        },
        -- theme = "dropdown",
      },
    },
    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key",
        },
      },
    },
  },
}
