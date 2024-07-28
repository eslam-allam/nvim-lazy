return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    { "pbogut/vim-dadbod-ssh", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },

  keys = {
    { "gSt", "<cmd>DBUIToggle<CR>", desc = "Toggle database client", mode = { "n" } },
    { "gSa", "<cmd>DBUIAddConnection<CR>", desc = "Add database client connection", mode = { "n" } },
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
