-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- use `vim.keymap.set` instead
--

local helpers = require("config.helpers")

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
  local success = os.execute()
  if success then
    vim.notify("Succesfully killed all Gradle daemons", 2, {})
  else
    vim.notify("Failed to kill all Gradle daemons", 4, {})
  end
end, { desc = "Kill all Gradle daemons" })
