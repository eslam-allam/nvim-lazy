local config_path = "/home/eslamallam/.config/nvim/jdtls-custom-roots.yaml"
local M = {}

function M.File_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.tableToString(tbl)
    local str = "{"

    for key, value in pairs(tbl) do
        str = str .. string.format("[%s] = %s, ", key, tostring(value))
    end

    -- Remove the trailing comma and space if the table is not empty
    if next(tbl) then
        str = str:sub(1, -3)
    end

    str = str .. "}"

    return str
end

function M.get_gradle_projects(gradlew_root)
	local output = vim.fn.system({
		gradlew_root .. "/gradlew",
		"projects",
		"--quiet",
		"--build-file",
		gradlew_root .. "/build.gradle"
	})
	local subprojects = {'root'}

  for subproject in output:gmatch("':([a-zA-Z0-9\\-]*)'") do
    table.insert(subprojects, subproject)
  end
	return subprojects
end

function M.ReadFile(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

local lyaml = require("lyaml")

function M.Expand_home(path)
  local home = os.getenv("HOME")
  if home == nil then
    return path
  end

  if string.sub(path, 1, 1) ~= "~" then
    return path
  end

  return home .. string.sub(path, 2, string.len(path))
end

function M.User_configured_root_dir(fileName)
  local exists = M.File_exists(config_path)
  local expanded_fname = M.Expand_home(fileName)
  if exists then
    local content = lyaml.load(M.ReadFile(config_path))

    for _, v in pairs(content) do
      local working_dir = M.Expand_home(v.working_dir)
      if string.sub(expanded_fname, 1, string.len(working_dir)) == working_dir then
        return v.root
      end
    end

    return
  end
  return require("lspconfig.server_configurations.jdtls").default_config.root_dir(fileName)
end

function M.User_configured_gradlew(root)
  local exists = M.File_exists(config_path)
  if exists then
    local content = lyaml.load(M.ReadFile(config_path))

    for _, v in pairs(content) do
      local conf_root = M.Expand_home(v.root)
      if root == conf_root then
        return root .. '/' .. v.gradlew_dir .. '/gradlew'
      end
    end

    return
  end
  return vim.fn.findfile('gradlew', root)
end
return M
