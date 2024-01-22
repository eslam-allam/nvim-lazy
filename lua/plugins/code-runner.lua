return {
  "CRAG666/code_runner.nvim",

  keys = {
    {"<leader>cc", "<cmd>RunCode<CR>", desc = "Run code", mode = { "n" }}
  },

  opts = {
    filetype = {
      go = "go run"
    },
    focus = false,
  }
}
