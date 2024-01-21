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
      project = {
        base_dirs = {
          "~/personal_projects",
          "~/ADRI",
          "~/.config",
        },
        cd_scope = { "tab", "window", "global" },
        -- theme = "dropdown",
        on_project_selected = function(prompt_bufnr)
          local project_actions = require("telescope._extensions.project.actions")
          -- Do anything you want in here. For example:
          project_actions.find_project_files(prompt_bufnr, false)
          vim.api.nvim_cmd({ cmd = "BufferLineCloseOthers" }, {})
          vim.cmd("bd")
        end,
      },
      file_browser = {
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,
      },
    },

    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key",
          ["<a-f>"] = browse_files,
          ["<a-u>"] = find_all_files,
        },
      },
    },
  },
}
