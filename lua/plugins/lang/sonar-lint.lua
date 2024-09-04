local javaExec = require("modules.java").execAtleast(17)
return {
  -- Have to configure once per lang as currently languages overlap.
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-jdtls",
    },
    ft = "java",
    enabled = true,
    config = function()
      require("sonarlint").setup({
        server = {
          cmd = {
            javaExec,
            "-jar",
            vim.fn.expand("$MASON/packages/sonarlint-language-server/extension/server/sonarlint-ls.jar"),
            -- Ensure that sonarlint-language-server uses stdio channel
            "-stdio",
            "-analyzers",
            -- paths to the analyzers you need, using those for python and java in this example
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
          },
        },
        filetypes = {
          "java",
        },
      })
    end,
  },
}
