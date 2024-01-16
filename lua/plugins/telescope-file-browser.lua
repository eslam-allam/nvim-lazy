local Util = require("lazyvim.util")
return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },

  keys = {
    { "<leader>fs", "<cmd>Telescope file_browser<CR>", desc = "Telescope File Browser (root)", mode = { "n" } },
    {
      "<leader>fS",
      "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
      desc = "Telescope File Browser (cwd)",
      mode = "n",
    },
  },

  config = function()
    Util.on_load("telescope.nvim", function()
      require("telescope").load_extension("file_browser")
    end)
  end,
}
