return {
  {
    "lervag/vimtex",
    dependencies = {
      "micangl/cmp-vimtex",
      {
        "saghen/blink.cmp",
        optional = true,
        dependencies = { "saghen/blink.compat" },
        opts = {
          sources = {
            compat = { "vimtex" },
          },
        },
      },
    },
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = "zathura"
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, { "bibtex-tidy", "latexindent", "tex-fmt" })
    end,
  },
}
