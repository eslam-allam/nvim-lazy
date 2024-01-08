return {
  "crnvl96/lazydocker.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>k", "<cmd>LazyDocker<CR>", desc = "Open Lazy Docker", mode = { "n" } },
  },
  opts = {}, -- automatically calls `require("lazydocker").setup()`
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}
