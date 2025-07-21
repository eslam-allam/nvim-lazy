return {
  "yujinyuz/gitpad.nvim",
  opts = {
    on_attach = function(bufnr)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-q>", "<Cmd>wq<CR>", { noremap = true, silent = true })
    end,
    floating_win_opts = {
      focusable = true,
    },
  },
  init = function()
    require("which-key").add({
      "<leader>gn",
      desc = "Git Notes",
      {
        "<leader>gnp",
        function()
          require("gitpad").toggle_gitpad({ title = "Project notes" })
        end,
        desc = "gitpad project",
      },
      {
        "<leader>gnb",
        function()
          require("gitpad").toggle_gitpad_branch({ title = "Branch notes" })
        end,
        desc = "gitpad branch",
      },
      -- Daily notes
      {
        "<leader>gnd",
        function()
          local date_filename = "daily-" .. os.date("%Y-%m-%d.md")
          require("gitpad").toggle_gitpad({ filename = date_filename, title = "Daily notes" })
        end,
        desc = "gitpad daily notes",
      },
      -- Per file notes
      {
        "<leader>gnf",
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
    }, {})
  end,
}
