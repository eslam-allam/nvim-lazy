return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local go_to_definition = function()
        vim.lsp.buf.definition({
          on_list = function(options)
            if options == nil or options.items == nil or #options.items == 0 then
              return
            end

            local targetFile = options.items[1].filename
            local prefix = string.match(targetFile, "(.-)_templ%.go$")

            if prefix then
              local function_name = vim.fn.expand("<cword>")
              options.items[1].filename = prefix .. ".templ"
              local qflist = vim.fn.getqflist()
              vim.fn.setqflist(options.items, " ")
              vim.api.nvim_command("cfirst")
              vim.fn.setqflist(qflist, " ")
              vim.api.nvim_command("silent! /templ " .. function_name)
            else
              vim.lsp.buf.definition()
            end
          end,
        })
      end

      opts.servers.gopls = {
        keys = { { "gd", go_to_definition, desc = "Goto Definition (Templ Aware)" } },
      }
    end,
  },
  {
    "maxandron/goplements.nvim",
    ft = "go",
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.htmx = {
        mason = false,
      }

      opts.servers["*"].capabilities.workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = true,
        },
      }
      -- Enable completion in wire template file
      opts.setup.gopls = function(_, sopts)
        sopts.settings = {
          gopls = {
            buildFlags = { "-tags=wireinject" },
          },
        }
      end
    end,
  },
}
