return {
  "chrisgrieser/nvim-rip-substitute",
  keys = {
    {
      "<leader>sf",
      function()
        require("rip-substitute").sub()
      end,
      mode = { "n", "x" },
      desc = " rip substitute",
    },
  },
  opts = {
    popupWin = {
      position = "top",
    },
  },
}
