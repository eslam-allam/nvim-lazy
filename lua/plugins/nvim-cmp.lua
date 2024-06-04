local cmp = require("cmp")
return {
  {
    "nvim-cmp",
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
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    },
  },
}
