return {
  "ecthelionvi/NeoColumn.nvim",
  keys = {
    { "<leader>h", "<cmd>ToggleNeoColumn<CR>", desc = "Toggle NeoColumn", mode = { "n" } },
  },
  opts = {
    always_on = true,
    custom_NeoColumn = {
      python = "80",
      java = "100",
    },
  },
}
