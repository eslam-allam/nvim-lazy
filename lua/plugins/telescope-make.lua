return {
  "sopa0/telescope-makefile",

  keys = {
    { "<leader>m", "<cmd>Telescope make<CR>", desc = "Make", mode = { "n" } },
  },

  config = function()
    Util.on_load("telescope.nvim", function()
      require("telescope").load_extension("make")
    end)
  end,
}
