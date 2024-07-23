return {
  "crnvl96/lazydocker.nvim",
  event = "VeryLazy",
  keys = {
    -- stylua: ignore
    { "<leader>k", function () require("lazyvim.util").terminal({'lazydocker'}) end, desc = "Open Lazy Docker", mode = { "n" } },
  },
  opts = {}, -- automatically calls `require("lazydocker").setup()`
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}
