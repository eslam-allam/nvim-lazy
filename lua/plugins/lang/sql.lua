return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters.sqlfluff = {
        args = { "format", "-" },
      }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        sqlfluff = {
          args = {
            "lint",
            "--format=json",
          },
        },
      },
    },
  },
  {
    "Maxteabag/sqlit.nvim",
    opts = {},
    keys = {
      {
        "<leader>D",
        function()
          require("sqlit").open()
        end,
        desc = "Database (sqlit)",
      },
    },
  },
}
