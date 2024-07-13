return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "modern",
    },
  },
  {
    "Bekaboo/deadcolumn.nvim",
    config = function(_, _)
      vim.api.nvim_create_autocmd("FileType", {
        desc = "deadcolumn config",
        pattern = { "java", "go", "python", "lua" },
        command = "setlocal colorcolumn=80",
      })
    end,
  },
  {
    "mvllow/modes.nvim",
    opts = {
      set_number = false,
    },
    config = true,
  },
}
