return {
  "NStefan002/speedtyper.nvim",
  cmd = "Speedtyper",
  keys = {
    { "<localleader>t", "<cmd>Speedtyper<CR>", mode = "n", desc = "Typing Test" },
  },
  opts = {
    window = {
      close_with = { n = "q", i = "<M-q>" },
    },
  },
}
