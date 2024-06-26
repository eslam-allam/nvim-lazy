Util = require("lazyvim.util")
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

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
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
      color = Util.ui.fg("Special"),
    })

    table.insert(opts.sections.lualine_x, "rest")

    table.insert(opts.sections.lualine_y, 1, {
      function()
        return require("recorder").displaySlots()
      end,
      color = Util.ui.fg("Special"),
    })
  end,
}
