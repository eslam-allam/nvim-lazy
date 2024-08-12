-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local ugroup = require("modules.helpers").ugroup

local cmd = vim.api.nvim_create_autocmd

cmd("TermOpen", {
  callback = function()
    local envSelector = require("venv-selector")
    local selectedEnv = envSelector.venv()
    if selectedEnv ~= nil then
      local activateCommand = 'source "' .. selectedEnv:match("(.*/)") .. 'activate"'
      local condaPrefix = os.getenv("CONDA_PREFIX")
      if type(condaPrefix) ~= "string" then
        vim.notify_once("[TermEnv] Invalid conda prefix!")
        return
      end
      if selectedEnv:sub(0, string.len(condaPrefix)) == condaPrefix then
        activateCommand = "conda activate " .. envSelector.venv()
      end
      vim.cmd('call chansend(b:terminal_job_id, "' .. activateCommand .. ' \\<cr>")')
    end
  end,
})

-- Dadbod Auto complete
cmd({
  "FileType",
}, {
  pattern = {
    "sql",
    "mysql",
    "plsql",
  },
  callback = function()
    require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" }, { name = "buffer" } } })
  end,
})

-- octo
cmd("FileType", {
  pattern = "octo",
  callback = function()
    vim.keymap.set("i", "@", "@<C-x><C-o>", { silent = true, buffer = true })
    vim.keymap.set("i", "#", "#<C-x><C-o>", { silent = true, buffer = true })
  end,
})

-- Tab Width
cmd("FileType", {
  pattern = {
    "lua",
    "sh",
    "zsh",
    "c",
    "cpp",
    "rust",
    "html",
    "javascript",
    "svelte",
    "json",
    "yaml",
    "xml",
    "xsd",
    "templ",
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

-- close some filetypes with <q>
cmd("FileType", {
  group = ugroup("close_with_q"),
  pattern = {
    "toggleterm",
    "http",
    "gitgraph",
    "DiffviewFiles",
  },
  callback = function(event)
    ---@type string|function
    local closeCommand = function()
      vim.api.nvim_buf_delete(event.buf, {})
    end
    if LazyVim.has("kulala.nvim") and event.match == "http" then
      closeCommand = function()
        require("kulala").close()
      end
    elseif event.match == "DiffviewFiles" then
      closeCommand = "<cmd>DiffviewClose<CR>"
    else
      vim.bo[event.buf].buflisted = false
    end
    vim.keymap.set("n", "q", closeCommand, { buffer = event.buf, silent = true })
  end,
})
