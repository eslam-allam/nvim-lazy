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
init = function()
    if vim.fn.argc(-1) == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("telescope").extensions.file_browser.file_browser()
      end
    end
  end,
  config = function()
    Util.on_load("telescope.nvim", function()
      require("telescope").load_extension("file_browser")
    end)
  end,
}
