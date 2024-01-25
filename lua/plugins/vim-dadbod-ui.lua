return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    { "eslam-allam/vim-dadbod-ssh", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },

  keys = {
    { "<leader>cst", "<cmd>DBUIToggle<CR>", desc = "Toggle database client", mode = { "n" } },
    { "<leader>csa", "<cmd>DBUIAddConnection<CR>", desc = "Add database client connection", mode = { "n" } },
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
