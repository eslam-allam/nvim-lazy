return {
  "williamboman/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}

    --- Java
    vim.list_extend(opts.ensure_installed, { "sonarlint-language-server", "gradle-language-server", "jdtls" })

    --- Bash
    vim.list_extend(opts.ensure_installed, { "bash-language-server" })

    -- Docker
    vim.list_extend(opts.ensure_installed, { "docker-compose-language-service", "dockerfile-language-server" })

    -- PHP
    vim.list_extend(opts.ensure_installed, { "intelephense" })

    -- Config files
    vim.list_extend(opts.ensure_installed, { "yaml-language-server", "json-lsp", "prettierd", "stylua", "yamllint", "jsonlint", "taplo" })
  end,
}
