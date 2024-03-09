return {
  "ecthelionvi/NeoColumn.nvim",
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
