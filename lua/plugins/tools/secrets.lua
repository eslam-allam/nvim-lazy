return {
  dir = require("plenary.path"):new(vim.fn.stdpath("config")):joinpath("lua", "local-plugins", "secrets"):absolute(),
  config = true,
  name = "secrets",
  lazy = false
}
