return {
  -- Have to configure once per lang as currently languages overlap.
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
    name = "sonarlint-java",
    ft = "java",
    config = function()
      require("sonarlint").setup({
        server = {
          cmd = {
            "sonarlint-language-server",
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
    name = "sonarlint-python",
    ft = "python",
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
          },
        },
        filetypes = {
          "python",
        },
      })
    end,
  },
}
