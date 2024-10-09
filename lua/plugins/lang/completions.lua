return {
  {
    "nvim-cmp",
    dependencies = {
      { "onsails/lspkind.nvim" },
    },
    keys = function()
      return {
        {
          "<c-tab>",
          function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next"
              or vim.notify("[LuaSnip] No more Results", vim.log.levels.WARN)
          end,
          expr = true,
          silent = true,
          mode = { "i", "s" },
        },
        {
          "<tab>",
          function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next"
              or vim.notify("[LuaSnip] No more Results", vim.log.levels.WARN)
          end,
          expr = true,
          silent = true,
          mode = { "s" },
        },
        {
          "<s-tab>",
          function()
            return require("luasnip").jumpable(-1) and "<Plug>luasnip-jump-prev"
              or vim.notify("[LuaSnip] No more Results", vim.log.levels.WARN)
          end,
          expr = true,
          silent = true,
          mode = { "i", "s" },
        },
      }
    end,
    opts = {
      window = {
        completion = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
          col_offset = -3,
          side_padding = 0,
        },
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            symbol_map = require("modules.completion-styler").getIcons(),
          })(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          kind.menu = "    (" .. (strings[2] or "") .. ")"

          return kind
        end,
      },
    },
  },
}
