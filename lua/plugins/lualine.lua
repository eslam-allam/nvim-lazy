Util = require("lazyvim.util")
local icons = require("lazyvim.config").icons
local function envSection(envName)
  return " " .. envName .. " "
end

local function pythonEnv()
  -- @type string
  local activeEnv = require("venv-selector").get_active_venv()
  if activeEnv ~= nil then
    return envSection(activeEnv:match("([%w-]+)$"))
  else
    return ""
  end
end

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    sections = {
      lualine_z = {
        {
          pythonEnv,
          cond = function()
            return pythonEnv() ~= ""
          end,
          color = Util.ui.fg("Special"),
        },
        {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      lualine_x = {
        {
          function()
            return require("recorder").recordingStatus()
          end,
          cond = function()
            return package.loaded["recorder"] and require("recorder").recordingStatus() ~= ""
          end,
          color = Util.ui.fg("Statement"),
        },
 -- stylua: ignore
        {
          function() return require("noice").api.status.command.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = Util.ui.fg("Statement"),
        },
        -- stylua: ignore
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = Util.ui.fg("Constant"),
        },
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
          color = Util.ui.fg("Debug"),
        },
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = Util.ui.fg("Special"),
        },
        {
          "diff",
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            removed = icons.git.removed,
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },
      lualine_y = {
        {
          function()
            return require("recorder").displaySlots()
          end,
          color = Util.ui.fg("Special"),
        },
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
    },
  },
}
