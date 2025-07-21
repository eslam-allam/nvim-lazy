local M = {}

local icons = {}

---add icon to registery
---@param category string
---@param icon string
function M.addIcon(category, icon)
  icons[category] = icon
end

---get icon by category
---@param category string
---@return string | nil
function M.getIcon(category)
  return icons[category]
end

local function shallow_copy(orig)
  local copy = {}
  for k, v in pairs(orig) do
    copy[k] = v
  end
  return copy
end

function M.getIcons()
  return shallow_copy(icons)
end

return M
