return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches" },
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
          vim.api.nvim_cmd({cmd = 'BufferLineCloseOthers'}, {})
          vim.cmd('bd')

        end,
      },
    },
    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key",
        },
      },
    },
  },
}
