return {
  {
    "lervag/vimtex",
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = "zathura"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, { "bibtex-tidy", "latexindent" })
    end,
  },
}
