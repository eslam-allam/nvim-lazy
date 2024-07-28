return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "abeldekat/harpoonline",
    version = "*",
    opts = {
      formatter_opts = {
        default = {
          max_slots = 5,
        },
      },
      on_update = function()
        require("lualine").refresh()
      end,
    },
  },
  opts = function(_, opts)
    local util = require("lazyvim.util")
    local function envSection(envName)
      return " " .. envName
    end

    local function pythonEnv()
      -- @type string
      local activeEnv = require("venv-selector").venv()
      if activeEnv ~= nil then
        return envSection(activeEnv:match("([%w-]+)$"))
      else
        return ""
      end
    end

    table.insert(opts.sections.lualine_b, 2, require("harpoonline").format)

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
      color = util.ui.fg("Special"),
    })

    table.insert(opts.sections.lualine_x, "rest")

    table.insert(opts.sections.lualine_y, 1, {
      function()
        return require("recorder").displaySlots()
      end,
      color = util.ui.fg("Special"),
    })
  end,
}
