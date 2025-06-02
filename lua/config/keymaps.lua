-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- use `vim.keymap.set` instead

local helpers = require("modules.helpers")
local Util = require("snacks")
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

if vim.fn.executable("lazydocker") == 1 then
      require("which-key").add({
        {
          "<leader>kd",
          function ()
            Util.terminal("lazydocker")
          end,
          desc = "Open Lazy Docker",
          mode = { "n" },
          icon = { cat = "filetype", name = "DockerFile" },
        },
      }, {})
end

vim.keymap.set("n", "<leader>f1", function()
  Util.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Open Term 1" })

for i = 2, 5 do
  vim.keymap.set("n", "<leader>f" .. tostring(i), function()
    Util.terminal(nil, { cwd = LazyVim.root(), env = {
      ["SNACKS_TERM"] = tostring(i),
    } })
  end, { desc = "Open Term " .. tostring(i) })
end

-- diagnostic
vim.keymap.set("n", "<leader>cD", function()
  vim.diagnostic.open_float()
  vim.diagnostic.open_float()
end, { desc = "Line Diagnostics (Focus)" })

if vim.g.neovide then
  -- Allow clipboard copy paste in neovim
  vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', { noremap = true, silent = true})
  vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', { noremap = true, silent = true})
  vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', { noremap = true, silent = true})
  vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', { noremap = true, silent = true})
end

-- Plugins
