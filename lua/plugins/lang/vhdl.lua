return {
  lazy = false,
  dir = require("plenary.path"):new(vim.fn.stdpath("config")):joinpath("lua", "local-plugins", "vhdl"):absolute(),
  name = "vhdl-tools",
  config = true,
  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "rust_hdl" })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "vhdl" })
      end,
    },
    {
      "stevearc/conform.nvim",
      opts = function(_, opts)
        opts.formatters_by_ft.vhdl = { "vhdlfmt" }
        opts.formatters["vhdlfmt"] = {
          inherit = false,
          command = "vhdlfmt",
          args = { "--print-width", 80, "--write", "$FILENAME" },
          stdin = false,
        }
      end,
    },
    {
      "nvimtools/none-ls.nvim",
      optional = true,
      dependencies = {
        {
          "mason-org/mason.nvim",
          opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "vsg" })
          end,
        },
      },
      opts = function(_, opts)
        local null_ls = require("null-ls")
        local helpers = require("null-ls.helpers")
        local vsg_lint = {
          name = "VSG",
          method = null_ls.methods.DIAGNOSTICS,
          filetypes = { "vhdl" },
          generator = helpers.generator_factory({
            command = "vsg",
            args = function(params)
              local rv = {}
              -- check if there is a config file in the root directory, if so
              -- insert the -c argument with it
              if vim.fn.filereadable(params.root .. "/vsg_config.yaml") == 1 then
                table.insert(rv, "-c=" .. params.root .. "/vsg_config.yaml")
              end
              table.insert(rv, "--stdin")
              table.insert(rv, "-of=syntastic")
              return rv
            end,
            cwd = nil,
            check_exit_code = { 0, 1 },
            from_stderr = false,
            ignore_stderr = true,
            to_stdin = true,
            format = "line",
            multiple_files = false,
            on_output = helpers.diagnostics.from_patterns({
              {
                pattern = [[(%w+).*%((%d+)%)(.*)%s+%-%-%s+(.*)]],
                groups = { "severity", "row", "code", "message" },
                overrides = {
                  severities = {
                    -- 2 is for warnings, nvim showing as an error can be obnoxious. Change if desired
                    ["ERROR"] = 2,
                    ["WARNING"] = 3,
                    ["INFORMATION"] = 3,
                    ["HINT"] = 4,
                  },
                },
              },
            }),
          }),
        }

        local vsg_format = {
          name = "VSG Formatting",
          method = null_ls.methods.FORMATTING,
          filetypes = { "vhdl" },
          generator = helpers.formatter_factory({
            command = "vsg",
            args = function(params)
              local rv = {}
              -- check if there is a config file in the root directory, if so
              -- insert the -c argument with it
              if vim.fn.filereadable(params.root .. "/vsg_config.yaml") == 1 then
                table.insert(rv, "-c=" .. params.root .. "/vsg_config.yaml")
              end
              table.insert(rv, "-f=$FILENAME")
              table.insert(rv, "-of=syntastic")
              table.insert(rv, "--fix")
              return rv
            end,
            cwd = nil,
            check_exit_code = { 0, 1 },
            ignore_stderr = true,
            to_temp_file = true,
            from_temp_file = true,
            to_stdin = false,
            multiple_files = false,
          }),
        }

        opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, { vsg_lint, vsg_format })
      end,
    },
  },
}
