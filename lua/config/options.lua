-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

local config_home = os.getenv("XDG_CONFIG_HOME") or "~/.config"

vim.env.JAVA_RUNTIMES_JSON = config_home .. "/nvim/config-files/jdtls/java-runtimes.json"
vim.env.CUSTOM_JAVA_ROOTS = config_home .. "/nvim/config-files/jdtls/jdtls-custom-roots.json"

vim.g.root_spec = { "lsp", { ".git" }, "cwd" }
vim.g.java_filetypes = { "java" }

vim.g.spring_cache_dir = vim.fn.expand("~/.local/share/nvim/spring-boot")

vim.g.hover_exclude_lsps = { { name = "spring-boot", filetypes = { "java" } } }
vim.g.definition_exclude_lsps = {
  { name = "spring-boot", filetypes = { "java" }, ts_captures = { "!string" } },
  { name = "jdtls", filetypes = { "java" }, ts_captures = { "string" } },
}
