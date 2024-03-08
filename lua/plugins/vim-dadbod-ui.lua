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
    { "<leader>cSt", "<cmd>DBUIToggle<CR>", desc = "Toggle database client", mode = { "n" } },
    { "<leader>cSa", "<cmd>DBUIAddConnection<CR>", desc = "Add database client connection", mode = { "n" } },
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    local wk = require("which-key")
    wk.register({
      S = {
        name = "Database",
        t = { "<cmd>DBUIToggle<CR>", "Toggle database client" },
        a = { "<cmd>DBUIAddConnection<CR>", "Add database client connection" },
      },
    }, { prefix = "<leader>c", mode = "n" })
  end,
}
