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
              local key = ""
              local needsWrite = false
              if not vim.g.intelephense_license_file then
                vim.notify(
                  "Intellephense license file not set. Premium features (Inlay Hints) may be disabled.",
                  vim.log.levels.WARN,
                  { title = "LSP Config" }
                )
              else
                key = require("modules.helpers").readOrDefault(vim.g.intelephense_license_file, function()
                  local result = vim.system({ "rbw", "get", "intelephense license key" }):wait()
                  if result.code ~= 0 then
                    vim.notify(
                      "Intelephense license key not found via rbw. Premium features (Inlay Hints) may be disabled.",
                      vim.log.levels.WARN,
                      { title = "LSP Config" }
                    )
                    return ""
                  end
                  needsWrite = true
                  return vim.trim(result.stdout)
                end)
              end

              key = vim.trim(key)

              if needsWrite then
                if vim.fn.mkdir(vim.fn.fnamemodify(vim.g.intelephense_license_file, ":h"), "p") == 1 then
                  vim.notify(
                    "Failed to create intelephense license key directory.",
                    vim.log.levels.WARN,
                    { title = "LSP Config" }
                  )
                  return key
                end
                if vim.fn.writefile({ key }, vim.g.intelephense_license_file, "w") == -1 then
                  vim.notify(
                    "Failed to write intelephense license key to file.",
                    vim.log.levels.WARN,
                    { title = "LSP Config" }
                  )
                end
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
