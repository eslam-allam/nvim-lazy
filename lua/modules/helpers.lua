local random = math.random

local M = {}

function M.cwd()
  return vim.fn.expand("%:p:h")
end

function M.uuid()
  math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 9)))

  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return (
    string.gsub(template, "[xy]", function(c)
      local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
      return string.format("%x", v)
    end)
  )
end

function M.splitStr(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function M.contains(array, value)
  for _, v in ipairs(array) do
    if v == value then
      return true
    end
  end
  return false
end


function M.stringEndsWith(str, suffix)
  return str:sub(-#suffix) == suffix
end


function M.get_gradle_projects(gradlew_root)
  local output = vim.fn.system({
    gradlew_root .. "/gradlew",
    "projects",
    "--quiet",
    "--build-file",
    gradlew_root .. "/build.gradle",
  })
  local subprojects = { "root" }

  for subproject in output:gmatch("':([a-zA-Z0-9\\-]*)'") do
    table.insert(subprojects, subproject)
  end
  return subprojects
end

function M.remove_value(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            table.remove(tbl, i)
            return true  -- Value removed successfully
        end
    end
    return false  -- Value not found in the table
end

return M
