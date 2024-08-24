return {
  "aspeddro/pandoc.nvim",
  init = function()
    require("modules.pandoc").setup()
  end,
  keys = {
    {
      "<leader>P",
      function()
        local directory = vim.fn.expand("%:p:h")
        local home = os.getenv("HOME")

        if home == nil then
          vim.notify("Could not find home directory", 4)
          return
        end
        local directoryWithoutHome = string.sub(directory, string.len(home) + 2)

        local outputDirectory = home .. "/Documents/pandoc/" .. directoryWithoutHome
        local fileName = vim.fn.expand("%:t")

        local extension = string.sub(fileName, string.len(fileName) - 1)

        if extension ~= "md" then
          vim.notify("[Pandoc] File is not Markdown", 4)
          return
        end
        local newName = string.sub(fileName, 0, string.len(fileName) - 2) .. "pdf"

        vim.system({ "mkdir", "-p", outputDirectory })

        require("pandoc.render").file(
          require("modules.pandoc").command({ ["--output"] = outputDirectory .. "/" .. newName })
        )
      end,
      desc = "Render PDF (Documents Dir)",
      mode = { "n" },
      ft = "markdown",
    },
    {
      "<leader>p",
      function()
        require("pandoc.render").file(require("modules.pandoc").command())
      end,
      desc = "Render PDF (cwd)",
      mode = { "n" },
      ft = "markdown",
    },
  },
  opts = {},
}
