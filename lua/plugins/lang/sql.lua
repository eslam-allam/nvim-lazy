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
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>D",
        function()
          require("dbee").toggle()
        end,
        desc = "Database",
      },
    },
    build = function()
      require("dbee").install()
    end,
    config = function(opts)
      require("dbee").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbee",
        callback = function(args)
          vim.api.nvim_buf_set_keymap(args.buf, "n", "q", "", {
            desc = "Close Dbee",
            noremap = true,
            silent = true,
            callback = function()
              require("dbee").close()
            end,
          })
        end,
      })
    end,
  },
}
