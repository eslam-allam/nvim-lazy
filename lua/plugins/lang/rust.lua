return {
  "alexpasmantier/krust.nvim",
  ft = "rust",
  cond = LazyVim.has_extra("lang.rust"),
  opts = {
    keymap = "<leader>cd", -- Set a keymap for Rust buffers (default: false)
    float_win = {
      border = "rounded", -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
      auto_focus = false, -- Auto-focus float (default: false)
    },
  },
}
