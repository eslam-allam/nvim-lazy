return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "Diff View", mode = "n" },
    { "<leader>gF", "<cmd>DiffviewFileHistory<CR>", desc = "File History (All)", mode = "n" },
  },
  opts = {
    keymaps = {
      view = {
        q = "<cmd>DiffviewClose<CR>",
      },
    },
  },
}
