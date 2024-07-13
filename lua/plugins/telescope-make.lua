return {
  "sopa0/telescope-makefile",
  cmd = "Telescope make",
  init = function()
    require("which-key").add({
      "<leader>m",
      "<cmd>Telescope make<CR>",
      desc = "Make",
      mode = { "n" },
      icon = { cat = "filetype", name = "make" },
    })
  end,
  config = function()
    Util.on_load("telescope.nvim", function()
      require("telescope").load_extension("make")
    end)
  end,
}
