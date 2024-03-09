-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local pythonFiles = vim.fn.globpath(vim.fn.getcwd(), "*.py", false, 1)
    if #pythonFiles > 0 then
      local venvSelector = require("venv-selector")
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
  callback = function()
    local envSelector = require("venv-selector")
    local selectedEnv = envSelector.get_active_path()
    if selectedEnv ~= nil then
      local activateCommand = 'source "' .. selectedEnv:match("(.*/)") .. 'activate"'
      local condaPrefix = os.getenv("CONDA_PREFIX")
      if type(condaPrefix) ~= "string" then
        vim.notify_once("[TermEnv] Invalid conda prefix!")
        return
      end
      if selectedEnv:sub(0, string.len(condaPrefix)) == condaPrefix then
        activateCommand = "conda activate " .. envSelector.get_active_venv()
      end
      vim.cmd('call chansend(b:terminal_job_id, "' .. activateCommand .. ' \\<cr>")')
    end
  end,
})

-- Dadbod Auto complete
vim.api.nvim_create_autocmd({
  "FileType",
}, {
  pattern = {
    "sql",
    "mysql",
    "plsql",
  },
  callback = function()
    require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
  end,
})

-- octo
vim.api.nvim_create_autocmd("FileType", {
  pattern = "octo",
  callback = function()
    vim.keymap.set("i", "@", "@<C-x><C-o>", { silent = true, buffer = true })
    vim.keymap.set("i", "#", "#<C-x><C-o>", { silent = true, buffer = true })
  end,
})

-- Tab Width
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "sh", "zsh", "c", "cpp", "rust" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
