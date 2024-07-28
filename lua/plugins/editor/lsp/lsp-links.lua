return {
  "icholy/lsplinks.nvim",
  config = function()
    require("noice")
    local lsplinks = require("lsplinks")
    lsplinks.setup()
    vim.keymap.set("n", "gx", lsplinks.gx)
  end,
}
