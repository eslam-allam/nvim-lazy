return {
  "preservim/vimux",
  keys = {
    { "<leader>vp", "<cmd>VimuxPromptCommand<CR>", desc = "[P]rompt run command in vmux runner" },
    { "<leader>vl", "<cmd>VimuxRunLastCommand<CR>", desc = "Run [l]ast command in vmux runner" },
    { "<leader>vq", "<cmd>VimuxCloseRunner<CR>", desc = "[Q]uit vmux runner" },
    { "<leader>vc", "<cmd>VimuxInterruptRunner<CR>", desc = "Interrupt vmux runner" },
    { "<leader>vr", "<cmd>VimuxClearTerminalScreen<CR>", desc = "Clear vmux runner" },
    { "<leader>vi", "<cmd>VimuxInspectRunner<CR>", desc = "[Inspect] to vmux runner" },
  },
}
