-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- use `vim.keymap.set` instead

local helpers = require("modules.helpers")
local Util = require("lazyvim.util")
local wk = require("which-key")

wk.add({
  "<leader>xd",
  group = "Delete",
  icon = { icon = "", color = "red" },
  { "<leader>xdq", "<cmd>cexpr [] | cclose<CR>", desc = "Clear QF list" },
})

wk.add({
  "<leader>cs",
  group = "Snap",
  mode = { "x" },
  icon = { icon = "", color = "purple" },
  { "<leader>csc", rhs = "<cmd>Snap<CR>", desc = "Snap to Clipboard" },
  { "<leader>csf", rhs = "<cmd>Snap type=file<CR>", desc = "Snap to file (cwd)" },
})

-- gradle
wk.add({
  "<leader>j",
  group = "Java",
  icon = { icon = "", color = "orange" },
  {
    "<leader>jg",
    group = "Gradle",
    icon = {icon = "", color = "azure"},
    {
      "<leader>jgq",
      group = "Kill",
      {
        "<leader>jgqc",
        rhs = function()
          local root = helpers.User_configured_root_dir(vim.api.nvim_buf_get_name(0))
          local gradlew = helpers.User_configured_gradlew(root)

          if gradlew == nil or gradlew:len() == 0 then
            vim.notify("Could not find gradlew in directory", 4, {})
          else
            local output = vim.fn.system({ gradlew, "--stop" })

            vim.notify(output, 2, {})
          end
        end,
        desc = "Kill current Gradle daemons",
      },
      {
        "<leader>jgqa",
        rhs = function()
          local _ = vim.fn.system({ "pkill", "-f", ".*GradleDaemon.*" })
          vim.notify("Succesfully killed all Gradle daemons", 2, {})
        end,
        desc = "Kill all Gradle daemons",
      },
    },
  },
})

if vim.fn.executable("spring-initializer") == 1 then
  vim.keymap.set("n", "<leader>js", function()
    Util.terminal("spring-initializer", { cwd = helpers.cwd() })
  end, { desc = "Spring Initializer" })
end

-- terminal
vim.keymap.set("n", "<leader>ft", function()
  Util.terminal(nil, { cwd = helpers.cwd() })
end, { desc = "Terminal (buf dir)" })

-- diagnostic
vim.keymap.set("n", "<leader>cD", function()
  vim.diagnostic.open_float()
  vim.diagnostic.open_float()
end, { desc = "Line Diagnostics (Focus)" })

-- Disabled
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grn")

-- Plugins
