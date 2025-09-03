return {
  "oribarilan/lensline.nvim",
  branch = "release/1.x",
  event = "LspAttach",
  config = function()
    require("lensline").setup()
  end,
}
