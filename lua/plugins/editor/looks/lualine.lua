return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    { "linux-cultist/venv-selector.nvim" },
  },
  opts = function(_, opts)
    if not vim.g.auto_color_scheme then
      opts.options.theme = "auto"
    else
      opts.options.theme = require("matugen").lualine()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MatugenReloaded",
        callback = function()
          require("lualine").setup({
            options = { theme = require("matugen").lualine() },
          })
        end,
      })
    end

    local function envSection(envName)
      return " " .. envName
    end

    local function pythonEnv()
      -- @type string
      local activeEnv = require("venv-selector").venv()
      if activeEnv ~= nil then
        return envSection(activeEnv:match("([%w-_]+)$"))
      else
        return ""
      end
    end

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
