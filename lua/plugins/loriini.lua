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
