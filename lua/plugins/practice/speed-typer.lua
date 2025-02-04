return {
  "NStefan002/speedtyper.nvim",
  branch = "v2",
  cmd = "Speedtyper",
  lazy = false,
  keys = {
    { "<localleader>t", "<cmd>Speedtyper<CR>", mode = "n", desc = "Typing Test" },
  },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "speedtyper",
      callback = function(evt)
        vim.api.nvim_buf_set_keymap(evt.buf, "n", "q", "<cmd>Speedtyper<CR>", { noremap = true, silent = true })
      end,
    })
  end,
}
