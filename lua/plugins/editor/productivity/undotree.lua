return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  keys = { -- load the plugin only when using it's keybinding:
    {
      "U",
      function()
        require("undotree").toggle()
      end,
      desc = "Toggle undotree",
    },
  },
  opts = {
    keymaps = {
      ["<Down>"] = "move_next",
      ["<Up>"] = "move_prev",
      ["<C-CR>"] = "move2parent",
      ["<C-Down>"] = "move_change_next",
      ["<C-Up>"] = "move_change_prev",
      ["<cr>"] = "action_enter",
      ["p"] = "enter_diffbuf",
      ["q"] = "quit",
    },
  },
}
