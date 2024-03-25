return {
  "norcalli/nvim-colorizer.lua",
  lazy = false,
  keys = {
    { "<leader>ch", "<cmd>ColorizerToggle<cr>", desc = "Toggle colorizer" },
  },
  config = function()
    require("colorizer").setup({
      "*";
      css = { css = true },
      svelte = { css = true },
      javascript = { css = true },
      typescript = { css = true },
    }, { names = false })
  end,
}
