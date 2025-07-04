return {
  {
    "lervag/vimtex",
    dependencies = {
      "micangl/cmp-vimtex",
      {
        "saghen/blink.cmp",
        optional = true,
        opts = {
          sources = {
            compat = { "vimtex" },
            providers = {
              supermaven = {
                kind = "Supermaven",
                score_offset = 100,
                async = true,
              },
            },
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
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, { "bibtex-tidy", "latexindent", "tex-fmt" })
    end,
  },
}
