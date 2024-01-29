return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>gpl", "<cmd>Octo pr list<CR>", desc = "List", mode = { "n" } },
    { "<leader>gpc", "<cmd>Octo pr create<CR>", desc = "Create", mode = { "n" } },
    { "<leader>gil", "<cmd>Octo issue list<CR>", desc = "List", mode = { "n" } },
    { "<leader>gic", "<cmd>Octo issue create<CR>", desc = "Create", mode = { "n" } },
    { "<leader>grs", "<cmd>Octo review start<CR>", desc = "Start", mode = { "n" } },
    { "<leader>grr", "<cmd>Octo review resume<CR>", desc = "Resume", mode = { "n" } },
    { "<leader>grc", "<cmd>Octo review close<CR>", desc = "Close", mode = { "n" } },
    { "<leader>grd", "<cmd>Octo review discard<CR>", desc = "Discard", mode = { "n" } },
  },
  cmd = "Octo",
  opts = {},
}
