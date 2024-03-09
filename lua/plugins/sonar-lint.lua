return {
  url = "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-jdtls"
  },
  name = "sonarlint",
  ft = { "java" },
  config = function()
    require("sonarlint").setup({
      server = {
        cmd = {
          "sonarlint-language-server",
          -- Ensure that sonarlint-language-server uses stdio channel
          "-stdio",
          "-analyzers",
          -- paths to the analyzers you need, using those for python and java in this example
          vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
          vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
          vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
        },
      },
      filetypes = {
        "java",
        "python"
      }
    })
  end,
}
