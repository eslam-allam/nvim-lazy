if vim.fn.executable("loriini") == 0 then
  vim.notify("'loriini' not found. Install to use color picker")
  return {}
end
return {
  "kolja/loriini.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "L", function() require("loriini").pick() end, desc = "Color Picker", mode = { "n" } },
  },
  opts = {
    bin = "loriini",
  },
}
