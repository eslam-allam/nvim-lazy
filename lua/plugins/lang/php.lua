return {
  {
    "jwalton512/vim-blade",
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "secrets",
        opts = {
          secrets = {
            intelephense = {
              generator = { "rbw", "get", "intelephense license key" },
            },
          },
        },
      },
    },
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.intelephense = {
        init_options = {
          licenceKey = require("secrets").get("intelephense"),
        },
      }
      opts.settings = opts.settings or {}
      opts.settings.intelephense = {
        inlayHints = {
          variableTypes = { enabled = true },
          parameterNames = { enabled = true },
          parameterTypes = { enabled = true },
        },
      }
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "phpcs",
        "phpcbf",
        "blade-formatter",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "phpcbf", "blade-formatter" },
      },
      formatters = {
        ["blade-formatter"] = {
          condition = function(_, ctx)
            return ctx.dirname:match("/view[s]?/")
          end,
        },
      },
    },
  },
}
