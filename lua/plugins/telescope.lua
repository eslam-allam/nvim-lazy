local Util = require("lazyvim.util")
local browse_files = function()
    require("telescope").extensions.file_browser.file_browser()
  end
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches" },
    { "<leader>fF", "<cmd>Telescope find_files<CR>", desc = "Find Files (cwd)" },
    { "<leader><Space>", "<cmd>Telescope find_files<CR>", desc = "Find Files (cwd)" },
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ cwd = Util.root()})
      end,
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
        },
      },
    },
  },
}
