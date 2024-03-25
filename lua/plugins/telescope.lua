local Util = require("lazyvim.util")
local helpers = require("config.helpers")
local browse_files = function()
    require("telescope").extensions.file_browser.file_browser()
  end
local find_all_files = function()
    local action_state = require("telescope.actions.state")
    local line = action_state.get_current_line()
    Util.telescope("find_files", { no_ignore = true, hidden = true, default_text = line })()  end
local find_root_files = function()
        require("telescope.builtin").find_files({ cwd = Util.root()})
      end

local find_cwd_files = function()
        require("telescope.builtin").find_files({ cwd = helpers.cwd() })
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
      mappings = {
        i = {
          ["<a-f>"] = browse_files,
          ["<a-u>"] = find_all_files,
          ["<a-F>"] = find_root_files,
        },
      },
    },
  },
}
