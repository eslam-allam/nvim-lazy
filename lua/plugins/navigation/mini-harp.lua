return {
  'vieitesss/miniharp.nvim',
  version = '*', -- latest stable release
  config = function (_, opts)
    local miniharp = require('miniharp')
    miniharp.setup(opts)

    vim.keymap.set('n', '<leader>H', miniharp.toggle_file, { desc = 'miniharp: toggle file mark' })
    vim.keymap.set('n', '<leader>h', miniharp.enter_list,  { desc = 'miniharp: enter marks list' })
    vim.keymap.set('n', '<leader>1', function() miniharp.go_to(1) end, { desc = 'miniharp: go to mark 1' })
    vim.keymap.set('n', '<leader>2', function() miniharp.go_to(2) end, { desc = 'miniharp: go to mark 2' })
    vim.keymap.set('n', '<leader>3', function() miniharp.go_to(3) end, { desc = 'miniharp: go to mark 3' })
    vim.keymap.set('n', '<leader>4', function() miniharp.go_to(4) end, { desc = 'miniharp: go to mark 4' })
  end,
  opts = {
    autoload = true,
    autosave = true,
    show_on_autoload = false,
    notifications = true,
    ui = {
      position = 'center', -- `top-left`, `top-right`, `bottom-left`, `bottom-right`.
      show_hints = true,
      enter = true, -- Whether to enter the floating window or not
    },
  },
}
