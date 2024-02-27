-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local helpers = require("config.helpers")

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local pythonFiles = vim.fn.globpath(vim.fn.getcwd(), "*.py", 0, 1)
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

-- Telescope preview cloak
local cloak = require("cloak")
local action_state = require("telescope.actions.state")
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(args)
    local buffer = require("telescope.state").get_existing_prompt_bufnrs()[1]
    local picker = action_state.get_current_picker(buffer)
    local base_name = vim.fn.fnamemodify(args.data.bufname, ":t")
    for _, pattern in ipairs(cloak.opts.patterns) do
      for _, file_pattern in ipairs(pattern.file_pattern) do
        if vim.fn.match(base_name, file_pattern) >= 0 then
          cloak.cloak(cloak.opts.patterns[1])
          picker:refresh_previewer()
          break
        end
      end
    end
  end,
  group = "cloak",
})
