return {
  "eslam-allam/Arduino-Nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    {
      "mason-org/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "arduino-language-server" })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        if type(opts.ensure_installed) == "table" then
          vim.list_extend(opts.ensure_installed, { "arduino" })
        end
      end,
    },
  },
  ft = "arduino",
  opts = {
    picker = "snacks",
  },
}
