return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    explorer = {
      replace_netrw = true,
    },
    image = {
      doc = {
        enabled = true,
        max_width = 80,
        max_height = 80,
      },
    },
    picker = {
      sources = {
        explorer = {
          layout = { preset = "default", preview = true },
          jump = { close = true },
        },
        git_log = {
          confirm = function(_, item)
            vim.cmd(":DiffviewOpen " .. item.commit .. "^!")
          end,
        },
        git_log_line = {
          confirm = function(_, item)
            vim.cmd(":DiffviewOpen " .. item.commit .. "^!" .. " -- " .. item.file)
          end,
        },
        git_log_file = {
          confirm = function(_, item)
            vim.cmd(":DiffviewOpen " .. item.commit .. "^!" .. " -- " .. item.file)
          end,
        },
      },
    },
  },
}
