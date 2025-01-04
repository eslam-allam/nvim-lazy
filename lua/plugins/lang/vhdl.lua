return {
  lazy = false,
  dir = require("plenary.path"):new(vim.fn.stdpath("config")):joinpath("lua", "local-plugins", "vhdl"):absolute(),
  config = true,
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "rust_hdl" })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "vhdl" })
      end,
    },
  },
}
