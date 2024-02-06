return {
  "ecthelionvi/NeoColumn.nvim",
  keys = {
    { "<leader>h", "<cmd>ToggleNeoColumn<CR>", desc = "Toggle NeoColumn", mode = { "n" } },
  },
  lazy = false,
  priority = 0,
  opts = {
    always_on = true,
    custom_NeoColumn = {
      python = "80",
      java = "100",
    },
    excluded_ft = {
      { "text", "markdown", "dashboard" },
    },
  },
}
