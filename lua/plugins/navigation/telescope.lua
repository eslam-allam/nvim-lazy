local Util = require("lazyvim.util")
local helpers = require("modules.helpers")
local browse_files = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  require("telescope").extensions.file_browser.file_browser({ default_text = line })
end
local find_all_files = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  require("telescope.builtin").find_files({ no_ignore = true, hidden = true, default_text = line })
end
local find_root_files = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  require("telescope.builtin").find_files({ cwd = Util.root(), default_text = line })
end

local find_cwd_files = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  require("telescope.builtin").find_files({ cwd = helpers.cwd(), default_text = line })
end

local function copy_selected_path(mode)
  if mode == nil then
    mode = "full"
  end

  local entry = require("telescope.actions.state").get_selected_entry()
  local path = entry.path
  local mode_name = "Full path"

  if mode == "relative" then
    path = require("plenary.path"):new(path):make_relative(vim.uv.cwd())
    mode_name = "Relative path"
  elseif mode == "basename" then
    path = vim.fs.basename(path)
    mode_name = "File name"
  end

  local cb_opts = vim.opt.clipboard:get()
  if vim.tbl_contains(cb_opts, "unnamed") then
    vim.fn.setreg("*", path)
  end
  if vim.tbl_contains(cb_opts, "unnamedplus") then
    vim.fn.setreg("+", path)
  end
  vim.fn.setreg("", path)

  vim.notify("[Telescope] " .. mode_name .. " copied to clipboard")
end

local group = vim.api.nvim_create_augroup("TelescopeImageView", { clear = true })

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
      preview = {
        check_mime_type = true,
        mime_hook = function(filepath, bufnr, opts)
          local chafa_installed = vim.fn.executable("chafa")
          if not chafa_installed then
            vim.notify_once("Chafa is not installed. Please install it to preview images.", vim.log.levels.WARN)
          end
          local is_image = function(filepath)
            local image_extensions = { "png", "jpg", "webp" } -- Supported image formats
            local split_path = vim.split(filepath:lower(), ".", { plain = true })
            local extension = split_path[#split_path]
            return vim.tbl_contains(image_extensions, extension)
          end
          if is_image(filepath) and LazyVim.has("image.nvim") then
            local image = require("image").from_file(
              filepath,
              { window = opts.winid, width = vim.api.nvim_win_get_width(opts.winid), with_virtual_padding = true }
            )
            if not image then
              return
            end
            image:render()
            local autocmd = vim.api.nvim_create_autocmd("User", {
              pattern = "TelescopePreviewerLoaded",
              group = group,
              callback = function(ev)
                if ev.buf == bufnr and image then
                  image:render()
                  return
                end
                image:clear(true)
              end,
            })
            local autocmd2 = nil
            autocmd2 = vim.api.nvim_create_autocmd("WinClosed", {
              pattern = tostring(opts.winid),
              group = group,
              callback = function(ev)
                image:clear(false)
                vim.api.nvim_del_autocmd(autocmd)
                if autocmd2 then
                  vim.api.nvim_del_autocmd(autocmd2)
                end
              end,
            })
            return
          end
          if chafa_installed and is_image(filepath) then
            local term = vim.api.nvim_open_term(bufnr, {})
            local function send_output(_, data, _)
              for _, d in ipairs(data) do
                vim.api.nvim_chan_send(term, d .. "\r\n")
              end
            end
            vim.fn.jobstart({
              "chafa",
              "-f",
              "symbols",
              "-s",
              tostring(vim.api.nvim_win_get_width(opts.winid)) .. "x" .. tostring(
                vim.api.nvim_win_get_height(opts.winid)
              ),
              filepath, -- Terminal image viewer command
            }, { on_stdout = send_output, stdout_buffered = true, pty = true })
          else
            require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
          end
        end,
      },
      path_display = { filename_first = { reverse_directories = false } },
      mappings = {
        i = {
          ["<a-y>"] = function()
            copy_selected_path("relative")
          end,
          ["<c-Y>"] = copy_selected_path,
          ["<a-Y>"] = function()
            copy_selected_path("basename")
          end,
          ["<a-f>"] = browse_files,
          ["<a-u>"] = find_all_files,
          ["<a-F>"] = find_root_files,
        },
        n = {
          ["<M-C-Y>"] = function()
            copy_selected_path("relative")
          end,
          ["<c-Y>"] = copy_selected_path,
          ["<a-Y>"] = function()
            copy_selected_path("basename")
          end,
        },
      },
    },
  },
}
