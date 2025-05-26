return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ltex-ls-plus" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex_plus = {},
      },
      setup = {
        ltex_plus = function(_, opts)
          if vim.fn.isdirectory(vim.g.ngram_data) == 0 then
            vim.notify("ngram data doesn't exist at '".. vim.g.ngram_data .. "'. Download to unlock full capabilities.", vim.log.levels.WARN, {
              title = "Spell",
            })
            return
          end
          opts.settings = {
            ltex = {
              additionalRules = {
                languageModel = vim.g.ngram_data,
              },
            },
          }
        end,
      },
    },
  },
}
