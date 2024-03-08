return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  init = function()
    local wk = require("which-key")
    wk.register({
      p = {
        name = "Pull Request",
        l = { "<cmd>Octo pr list<CR>", "List" },
        c = { "<cmd>Octo pr create<CR>", "Create" },
      },
      i = {
        name = "Issue",
        l = { "<cmd>Octo issue list<CR>", "List" },
        c = { "<cmd>Octo issue create<CR>", "Create" },
      },
      r = {
        name = "Review",
        s = { "<cmd>Octo review start<CR>", "Start" },
        r = { "<cmd>Octo review resume<CR>", "Resume" },
        c = { "<cmd>Octo review close<CR>", "Close" },
        d = { "<cmd>Octo review discard<CR>", "Discard" },
      },
    }, { prefix = "<leader>g" })
  end,
  config = true,
}
