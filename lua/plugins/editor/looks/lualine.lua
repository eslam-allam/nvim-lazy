return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    {
      "letieu/harpoon-lualine",
      dependencies = {
        { "ThePrimeagen/harpoon", lazy = false },
      },
    },
    opts = false,
    { "linux-cultist/venv-selector.nvim" },
  },
  opts = function(_, opts)
    local function envSection(envName)
      return " " .. envName
    end

    local function pythonEnv()
      -- @type string
      local activeEnv = require("venv-selector").python()
      local pythonExec = vim.fn.has("win32") == 1 and "\\python%.exe" or "/bin/python"
      if activeEnv ~= nil then
        return envSection(activeEnv:match("([%w-_]+)" .. pythonExec .. "$"))
      else
        return ""
      end
    end

    table.insert(opts.sections.lualine_b, 2, "harpoon2")

    table.insert(opts.sections.lualine_z, 1, {
      pythonEnv,
      cond = function()
        return pythonEnv() ~= ""
      end,
    })

    table.insert(opts.sections.lualine_x, 1, {
      function()
        return require("recorder").recordingStatus()
      end,
      color = function()
        return { fg = Snacks.util.color("Special") }
      end,
    })

    table.insert(opts.sections.lualine_x, "rest")

    table.insert(opts.sections.lualine_y, 1, {
      function()
        return require("recorder").displaySlots()
      end,
      color = function()
        return { fg = Snacks.util.color("Special") }
      end,
    })
  end,
}
