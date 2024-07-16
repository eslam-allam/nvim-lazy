return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      templ = { "templ", "injected" },
    },
    formatters = {
      injected = {
        options = {
          lang_to_formatters = {
            javascript = { "prettierd" },
          },
        },
      },
    },
  },
}
