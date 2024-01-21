-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- use `vim.keymap.set` instead
--

local helpers = require("config.helpers")
local Util = require("lazyvim.util")

-- gradle
vim.keymap.set("n", "<leader>tgqc", function()
  local root = helpers.User_configured_root_dir(vim.api.nvim_buf_get_name(0))
  local gradlew = helpers.User_configured_gradlew(root)

  if gradlew == nil or gradlew:len() == 0 then
    vim.notify("Could not find gradlew in directory", 4, {})
  else
    local output = vim.fn.system({ gradlew, "--stop" })

    vim.notify(output, 2, {})
  end
end, { desc = "Kill current Gradle daemons" })
vim.keymap.set("n", "<leader>tgqa", function()
  local _ = vim.fn.system({ "pkill", "-f", ".*GradleDaemon.*" })
  vim.notify("Succesfully killed all Gradle daemons", 2, {})
end, { desc = "Kill all Gradle daemons" })

-- lazygit
vim.keymap.set("n", "<leader>gg", function() Util.terminal({ "lazygit" }, {cwd = Util.root(), esc_esc = false, ctrl_hjkl = false}) end, { desc = "Lazygit (Root)" })
vim.keymap.set("n", "<leader>gG", function() Util.terminal({ "lazygit" }, {cwd = helpers.cwd(), esc_esc = false, ctrl_hjkl = false}) end, { desc = "Lazygit (cwd)" })

-- terminal
vim.keymap.set("n", "<leader>ft", function() Util.terminal(nil, { cwd = Util.root() }) end, { desc = "Terminal (Root)" })
vim.keymap.set("n", "<leader>fT", function() Util.terminal(nil, { cwd = helpers.cwd() }) end, { desc = "Terminal (cwd)" })
vim.keymap.set("n", "<C-/>", function() Util.terminal(nil, { cwd = Util.root() }) end, { desc = "Terminal (Root)" })

-- diagnostic
vim.keymap.set("n", "<leader>cD", function() vim.diagnostic.open_float(); vim.diagnostic.open_float() end, { desc = "Line Diagnostics (Focus)"})
