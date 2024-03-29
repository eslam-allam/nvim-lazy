return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "lua", "xml", "http", "json", "graphql" })
      end
    end,
  },
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "luarocks.nvim" },
    keys = {
      {
        "<leader>rr",
        "<cmd>Rest run<CR>",
        desc = "Run request under the cursor",
      },
      {
        "<leader>rR",
        "<cmd>Rest run last<CR>",
        desc = "Re-run latest request",
      },
    },
    config = function()
      require("rest-nvim").setup()
    end,
  },
}
