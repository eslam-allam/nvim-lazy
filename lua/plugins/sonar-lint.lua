local javaExec = require("modules.java").execAt(17)
return {
  -- Have to configure once per lang as currently languages overlap.
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
    dependencies = {
      "williamboman/mason.nvim",
    },
    name = "sonarlint-java",
    ft = "java",
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
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
    dependencies = {
      "williamboman/mason.nvim",
    },
    name = "sonarlint-python",
    ft = "python",
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
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
          },
        },
        filetypes = {
          "python",
        },
      })
    end,
  },
}
