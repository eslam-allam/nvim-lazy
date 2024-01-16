local Util = require("lazyvim.util")
return {
  "nvim-telescope/telescope-project.nvim",
  keys = {

    { "<leader>fp", "<cmd>Telescope project display_type=full<CR>", desc = "projects", mode = { "n" } },
  },
  config = function()
    Util.on_load("telescope.nvim", function()
      require("telescope").load_extension("project")
    end)
  end,
}
