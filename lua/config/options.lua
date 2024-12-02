-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"

if vim.fn.has("windows") == 1 then
  vim.opt.shell = '"C:/Program Files/Git/bin/bash.exe"'
end

vim.g.python3_host_prog = "~/miniconda3/envs/nvim/bin/python"

vim.g.maplocalleader = ","

vim.g.autoformat = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

local config_home = vim.fn.stdpath("config")

vim.env.FORMATTER_SCHEMA_DIR = config_home .. "/config-files/formatter-schemas"

local jdtls_config_dir = config_home .. "/config-files/jdtls"
vim.env.JAVA_RUNTIMES_JSON = jdtls_config_dir .. "/java-runtimes.json"
vim.env.JAVA_RUNTIMES_JSON_SCHEMA = jdtls_config_dir .. "/java-runtimes.schema.json"
vim.env.CUSTOM_JAVA_ROOTS = jdtls_config_dir .. "/jdtls-custom-roots.json"

vim.g.root_spec = { "lsp", { ".git" }, "cwd" }
vim.g.java_filetypes = { "java" }

vim.g.spring_cache_dir = vim.fn.expand("~/.local/share/nvim/spring-boot")

vim.g.hover_exclude_lsps = { { name = "spring-boot", filetypes = { "java" } } }
vim.g.definition_exclude_lsps = {
  { name = "spring-boot", filetypes = { "java" }, ts_captures = { "!string" } },
  { name = "jdtls", filetypes = { "java" }, ts_captures = { "string" } },
}

vim.g.custom_formater_exec_folder = vim.fn.expand("~/.local/share/nvim/conform/custom_formatters")
