local function envSection(envName)
  return " " .. envName .. " "
end

local function pythonEnv()
  -- @type string
  local activeEnv = require("venv-selector").get_active_venv()
  if activeEnv ~= nil then
    return envSection(activeEnv:match("([%w-]+)$"))
  else
    return envSection("No Env")
  end
end
return {
  "nvim-lualine/lualine.nvim",
  opts = {
    sections = {
      lualine_z = { pythonEnv },
    },
  },
}
