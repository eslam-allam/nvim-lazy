return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "MattiasMTS/cmp-dbee",
      dependencies = {
        { "kndndrj/nvim-dbee" },
      },
      ft = "sql", -- optional but good to have
      opts = {}, -- needed
    },
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          compat = { "cmp-dbee" },
        },
      },
    },
  },
  keys = {
    { "<leader>D", "<cmd>Dbee<CR>", desc = "Toggle DB", mode = "n" },
  },
  build = function()
    -- Install tries to automatically detect the install method.
    -- if it fails, try calling it with one of these parameters:
    --    "curl", "wget", "bitsadmin", "go"
    require("dbee").install()
  end,
  config = function()
    require("dbee").setup(--[[optional config]])
  end,
}
