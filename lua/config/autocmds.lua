-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local pythonFiles = vim.fn.globpath(vim.fn.getcwd(), "*.py", 0, 1)
    if #pythonFiles > 0 then
      local venvSelector = require("venv-selector")
      vim.notify_once("Detected " .. #pythonFiles .. " python files in current project.", 2)
      venvSelector.retrieve_from_cache()
      if venvSelector.get_active_venv() == nil then
        local condaEnv = os.getenv("CONDA_DEFAULT_ENV")
        local virtualEnv = os.getenv("VIRTUAL_ENV")
        local venvSelectorEnv = require("venv-selector.venv")
        local venvSelectorConfig = require("venv-selector.config")
        local selectedEnv = nil
        if virtualEnv ~= nil then
          vim.notify_once("Activating Virtual Env: " .. virtualEnv, 2)
          selectedEnv = virtualEnv
          venvSelectorEnv.set_venv_and_system_paths({ value = selectedEnv })
        elseif condaEnv ~= nil then
          vim.notify_once("Activating current condaEnv env: " .. condaEnv, 2)
          selectedEnv = venvSelectorConfig.settings.anaconda_envs_path .. "/" .. condaEnv
          if condaEnv == "base" then
            selectedEnv = venvSelectorConfig.settings.anaconda_base_path
          end
          venvSelectorEnv.set_venv_and_system_paths({
            value = selectedEnv,
          })
        end
        if selectedEnv ~= nil then
          venvSelectorEnv.cache_venv({ value = selectedEnv })
        end
      end
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(event)
    local envSelector = require("venv-selector")
    local selectedEnv = envSelector.get_active_path()
    if selectedEnv ~= nil then
      local activateCommand = 'source "' .. selectedEnv:match("(.*/)") .. 'activate"'
      local condaPrefix = os.getenv("CONDA_PREFIX")
      if selectedEnv:sub(0, string.len(condaPrefix)) == condaPrefix then
        activateCommand = "conda activate " .. envSelector.get_active_venv()
      end
      vim.cmd('call chansend(b:terminal_job_id, "' .. activateCommand .. ' \\<cr>")')
    end
  end,
})

vim.api.nvim_create_autocmd({
  "BufNewFile",
  "BufRead",
}, {
  pattern = { "*.gradle" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "java")
  end,
})

