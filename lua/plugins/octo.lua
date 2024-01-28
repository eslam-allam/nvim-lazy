return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {"<leader>gp", "<cmd>Octo pr list<CR>", desc = "Pull Requests", mode = { "n" }},
    {"<leader>gi", "<cmd>Octo issue list<CR>", desc = "Issues", mode = { "n" }},
    {"<leader>grs", "<cmd>Octo review start<CR>", desc = "Start", mode = { "n" }},
    {"<leader>grr", "<cmd>Octo review resume<CR>", desc = "Resume", mode = { "n" }},
    {"<leader>grc", "<cmd>Octo review close<CR>", desc = "Close", mode = { "n" }},
    {"<leader>grd", "<cmd>Octo review discard<CR>", desc = "Discard", mode = { "n" }},
  },
  cmd = "Octo",
  opts = {}
}
