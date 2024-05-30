local Util = require("lazyvim.util")
local helpers = require("modules.helpers")
local browse_files = function()
  require("telescope").extensions.file_browser.file_browser()
end
local find_all_files = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  Util.telescope("find_files", { no_ignore = true, hidden = true, default_text = line })()
end
local find_root_files = function()
  require("telescope.builtin").find_files({ cwd = Util.root() })
end

local find_cwd_files = function()
  require("telescope.builtin").find_files({ cwd = helpers.cwd() })
end

local function copy_selected_path(mode)
  if mode == nil then
    mode = 'full'
  end

  local entry = require("telescope.actions.state").get_selected_entry()
  local path = entry.path
  local mode_name = 'Full path'

  if mode == 'relative' then
    path = require("plenary.path"):new(path):make_relative(vim.uv.cwd())
    mode_name = 'Relative path'
    elseif mode == 'basename' then
      path = vim.fs.basename(path)
      mode_name = 'File name'
  end


  local cb_opts = vim.opt.clipboard:get()
  if vim.tbl_contains(cb_opts, "unnamed") then vim.fn.setreg("*", path) end
  if vim.tbl_contains(cb_opts, "unnamedplus") then
    vim.fn.setreg("+", path)
  end
  vim.fn.setreg("", path)

  vim.notify("[Telescope] ".. mode_name .. " copied to clipboard")
end

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>cb", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Find Symbol" },
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches" },
    { "<leader>fF", find_cwd_files, desc = "Find Files (cwd)" },
    { "<leader><Space>", find_root_files, desc = "Find Files (Root)" },
    {
      "<leader>ff",
      find_root_files,
      desc = "Find Files (Root)",
    },
  },
  opts = {
    extensions = {
      file_browser = {
        no_ignore = true,
        collapse_dirs = true,
        hijack_netrw = true,
      },
    },

    defaults = {
      path_display = { filename_first = { reverse_directories = false } },
      mappings = {
        i = {
          ["<c-y>"] = function ()
            copy_selected_path('relative')
          end,
          ["<c-Y>"] = copy_selected_path,
          ["<a-Y>"] = function ()
            copy_selected_path('basename')
          end,
          ["<a-f>"] = browse_files,
          ["<a-u>"] = find_all_files,
          ["<a-F>"] = find_root_files,
        },
        n = {
          ["<c-y>"] = function ()
            copy_selected_path('relative')
          end,
          ["<c-Y>"] = copy_selected_path,
          ["<a-Y>"] = function ()
            copy_selected_path('basename')
          end,
        }
      },
    },
  },
}
