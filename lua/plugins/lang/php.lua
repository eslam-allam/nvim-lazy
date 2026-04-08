return {
  {
    "jwalton512/vim-blade",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          init_options = {
            licenceKey = (function()
              local key = vim.fn.system("rbw get 'intelephense license key'")
              if vim.v.shell_error ~= 0 then
                vim.notify(
                  "Intelephense license key not found via rbw. Premium features (Inlay Hints) may be disabled.",
                  vim.log.levels.WARN,
                  { title = "LSP Config" }
                )
                return nil
              end
              return vim.trim(key)
            end)(),
          },
          settings = {
            intelephense = {
              inlayHints = {
                variableTypes = { enabled = true },
                parameterNames = { enabled = true },
                parameterTypes = { enabled = true },
              },
            },
          },
        },
      },
    },
  },
}
