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

vim.api.nvim_create_autocmd({
  "BufNewFile",
  "BufRead",
}, {
  pattern = { "*.gradle" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("filetype", "java", { buf = buf })
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

-- Handle cloaking the Telescope preview.
local cloak = require("cloak")
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(args)
    if not cloak.opts.enabled then
      return
    end

    local buffer = require("telescope.state").get_existing_prompt_bufnrs()[1]
    local picker = require("telescope.actions.state").get_current_picker(buffer)
    local base_name = vim.fn.fnamemodify(args.data.bufname, ":t")

    -- If our state variable is set, meaning we have just refreshed after cloaking a buffer,
    -- set the selection to that row again.
    if picker.__cloak_selection then
      picker:set_selection(picker.__cloak_selection)
      picker.__cloak_selection = nil
      vim.schedule(function()
        picker:refresh_previewer()
      end)
      return
    end

    local is_cloaked, _ = pcall(vim.api.nvim_buf_get_var, args.buf, "cloaked")

    -- Check the buffer agains all configured patterns,
    -- if matched, set a variable on the picker to know where we left off,
    -- set a buffer variable to know we already cloaked it later, and refresh.
    -- a refresh will result in the cloak being visible, and will make this
    -- aucmd be called again right away with the first result, which we will then
    -- set to what we have stored in the code above.
    for _, pattern in ipairs(cloak.opts.patterns) do
      -- Could be a string or a table of patterns.
      local file_patterns = pattern.file_pattern
      if type(file_patterns) == "string" then
        file_patterns = { file_patterns }
      end

      for _, file_pattern in ipairs(file_patterns) do
        if base_name ~= nil and base_name:match(file_pattern) ~= nil then
          cloak.cloak(pattern)
          vim.api.nvim_buf_set_var(args.buf, "cloaked", true)
          if is_cloaked then
            return
          end

          local row = picker:get_selection_row()
          picker.__cloak_selection = row
          picker:refresh()
          return
        end
      end
    end
  end,
  group = 'cloak',
})
