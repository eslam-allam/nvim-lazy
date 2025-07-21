-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local ugroup = require("modules.helpers").ugroup

local cmd = vim.api.nvim_create_autocmd

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
    "html",
    "javascript",
    "svelte",
    "json",
    "yaml",
    "xml",
    "xsd",
    "templ",
    "markdown",
    "vhdl",
    "tex",
    "bib",
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
    "k8s_*",
  },
  ---@param event vim.api.create_autocmd.callback.args
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
    elseif event.match:match("k8s_.*") then
      closeCommand = function()
        require("kubectl").close()
      end
    else
      vim.bo[event.buf].buflisted = false
    end
    vim.keymap.set("n", "q", closeCommand, { buffer = event.buf, silent = true })
  end,
})
