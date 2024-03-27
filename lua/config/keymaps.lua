-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- use `vim.keymap.set` instead

local helpers = require("modules.helpers")
local Util = require("lazyvim.util")
local wk = require("which-key")


wk.register({
    s = {
        name = "Snap",
        c = {"<cmd>Snap<CR>", "Snap to Clipboard"},
        f = {"<cmd>Snap type=file<CR>", "Snap to file (cwd)"}
    }
}, {prefix = "<leader>c", mode = "x"})

-- gradle
wk.register({
  j = {
    name = "java",
    g = {
      name = "gradle",
      q = {
        name = "kill",
        c = {
          function()
            local root = helpers.User_configured_root_dir(vim.api.nvim_buf_get_name(0))
            local gradlew = helpers.User_configured_gradlew(root)

            if gradlew == nil or gradlew:len() == 0 then
              vim.notify("Could not find gradlew in directory", 4, {})
            else
              local output = vim.fn.system({ gradlew, "--stop" })

              vim.notify(output, 2, {})
            end
          end,
          "Kill current Gradle daemons",
        },
        a = {
          function()
            local _ = vim.fn.system({ "pkill", "-f", ".*GradleDaemon.*" })
            vim.notify("Succesfully killed all Gradle daemons", 2, {})
          end,
          "Kill all Gradle daemons",
        },
      },
    },
  },
}, {prefix = "<leader>", filetype = "java"})


-- terminal
vim.keymap.set("n", "<leader>ft", function() Util.terminal(nil, { cwd = helpers.cwd() }) end, { desc = "Terminal (buf dir)" })

-- diagnostic
vim.keymap.set("n", "<leader>cD", function() vim.diagnostic.open_float()
vim.diagnostic.open_float() end, { desc = "Line Diagnostics (Focus)"})

-- Plugins
