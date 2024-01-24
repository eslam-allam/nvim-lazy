return {
"neovim/nvim-lspconfig",
  opts = {
    servers = {
      jdtls = {
        keys = {
          { "<leader>cjw", "<cmd>JdtWipeDataAndRestart<CR>", desc = "[W]ipe and Restart" },
          { "<leader>cjc", "<cmd>JdtCompile<CR>", desc = "[C]ompile" },
          { "<leader>cjs", "<cmd>JdtSetRuntime<CR>", desc = "[S]et Runtime" },
          { "<leader>cju", "<cmd>JdtUpdateConfig<CR>", desc = "[U]pdate Config" },
          { "<leader>cjr", "<cmd>JdtRestart<CR>", desc = "[R]estart" },
          { "<leader>cjj", "<cmd>JdtJshell<CR>", desc = "[J]Shell" },
        }
      }
    }
  }
}
