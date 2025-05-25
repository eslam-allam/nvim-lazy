-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local path = require("plenary.path")
local data_dir = path:new(vim.fn.stdpath("data"))

vim.o.termbidi = true
vim.o.arabicshape = false

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
end

if LazyVim.is_win() then
  vim.o.shell = 'powershell.exe -nologo'
end

local function get_conda_nvim_root()
  local cacheFile = path:new(vim.fn.stdpath("cache"), "conda_nvim_root.txt")
  if cacheFile:exists() then
    return cacheFile:read()
  end
  local condaEnvs = vim.system({ "conda", "info", "--envs" }):wait()
  local pythonFileName = LazyVim.is_win() and { "python.exe" } or { "bin", "python" }
  if condaEnvs.code ~= 0 then
    vim.notify("Could not find conda envs", vim.log.levels.WARN)
    return nil
  end
  local lines = vim.split(condaEnvs.stdout, "\n")
  for _, line in ipairs(lines) do
    if line:match("nvim.*") then
      local envFolder = vim.fn.trim(line:match("nvim%s+%*?(.*)"))
      local envPath = path:new(envFolder,  unpack(pythonFileName)):absolute()
      cacheFile:write(envPath, "w", 464)
      return envPath
    end
  end
  vim.notify("Could not find conda nvim env", vim.log.levels.WARN)
  return nil
end

if vim.fn.executable("conda") == 1 then
  local conda_env = get_conda_nvim_root()
  if conda_env then
    vim.g.python3_host_prog = conda_env
    vim.g.python_host_prog = conda_env
  end
end

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

vim.g.spring_cache_dir = data_dir:joinpath("spring-boot"):absolute()

vim.g.hover_exclude_lsps = { { name = "spring-boot", filetypes = { "java" } } }
vim.g.definition_exclude_lsps = {
  { name = "spring-boot", filetypes = { "java" }, ts_captures = { "!string" } },
  { name = "jdtls", filetypes = { "java" }, ts_captures = { "string" } },
}

vim.g.custom_formater_exec_folder = data_dir:joinpath("conform", "custom_formatters"):absolute()

vim.g.cmp_file_disabled =
  { "DressingInput", "TelescopePrompt", "snacks_input", "snacks_picker_input", "speedtyper", "rip-substitute" }

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.spell = true
