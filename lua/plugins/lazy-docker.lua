local Util = require("lazyvim.util")
return {
  "crnvl96/lazydocker.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>k", function () Util.terminal({'lazydocker'}) end, desc = "Open Lazy Docker", mode = { "n" } },
  },
  opts = {}, -- automatically calls `require("lazydocker").setup()`
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}
