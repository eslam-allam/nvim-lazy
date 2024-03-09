-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = false

vim.g.ray_options = {
  theme = "falcon",
  background = "true",
  darkMode = "true",
  padding = 16,
  language = "auto",
}

vim.g.python3_host_prog = "~/miniconda3/bin/python"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.env.JAVA_RUNTIMES_JSON = os.getenv("XDG_CONFIG_HOME") .. "/nvim/config-files/jdtls/java-runtimes.json"
vim.env.CUSTOM_JAVA_ROOTS = os.getenv("XDG_CONFIG_HOME") .. "/nvim/config-files/jdtls/jdtls-custom-roots.json"
