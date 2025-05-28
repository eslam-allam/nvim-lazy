return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "asm-lsp", "asmfmt" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "asm" })
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters.asmfmt = {
        command = "asmfmt",
        args = {},
        stdin = true,
      }

      opts.formatters_by_ft.asm = { "asmfmt" }
    end,
  },
}
