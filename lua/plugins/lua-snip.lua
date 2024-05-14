local cmp = require("cmp")
return {
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {
        {
          "<c-tab>",
          function()
            return require("luasnip").jump(1)
          end,
          expr = true,
          silent = true,
          mode = "i",
        },

    -- stylua: ignore
    { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },

    -- stylua: ignore
    { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
      }
    end,
  },
  {
    "nvim-cmp",
    opts = {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    },
  },
}
