return {
  "yujinyuz/gitpad.nvim",
  opts = {
    on_attach = function (bufnr)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>wq<CR>', { noremap = true, silent = true })
    end
  },
  keys = {
    {
      "<leader>pp",
      function()
        require("gitpad").toggle_gitpad({ title = "Project notes" })
      end,
      desc = "gitpad project",
    },
    {
      "<leader>pb",
      function()
        require("gitpad").toggle_gitpad_branch({ title = "Branch notes" })
      end,
      desc = "gitpad branch",
    },
    -- Daily notes
    {
      "<leader>pd",
      function()
        local date_filename = "daily-" .. os.date("%Y-%m-%d.md")
        require("gitpad").toggle_gitpad({ filename = date_filename, title = "Daily notes" })
      end,
      desc = "gitpad daily notes",
    },
    -- Per file notes
    {
      "<leader>pf",
      function()
        local filename = vim.fn.expand("%:p") -- or just use vim.fn.bufname()
        if filename == "" then
          vim.notify("empty bufname")
          return
        end
        filename = vim.fn.pathshorten(filename, 2) .. ".md"
        require("gitpad").toggle_gitpad({ filename = filename, title = "Current file notes" })
      end,
      desc = "gitpad per file notes",
    },
  },
}
