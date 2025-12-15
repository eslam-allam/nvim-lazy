local M = {
  ---@type table<string, string>
  runtimes = {},
}
local path = require("plenary.path")

local function versionFromKey(key)
  return tonumber(key:match("java(%d+)"))
end

if vim.fn.filereadable(vim.env.JAVA_RUNTIMES_JSON) == 1 then
  M.runtimes = vim.json.decode(table.concat(vim.fn.readfile(vim.env.JAVA_RUNTIMES_JSON), "\n"))
end

function M.To_java_version_name(path)
  -- Extract the basename from the path
  local basename = path:match("([^/]+)$")
  if not basename then
    return nil
  end

  -- Extract the version number between non-digits followed by digits
  local version = basename:match("-(%d+)")
  if not version then
    return nil
  end

  return "java" .. version
end

if vim.fn.executable("fd") == 1 and not LazyVim.is_win() then
  local paths_result = vim.system({ "fd", "bin/java$", "/usr/lib/jvm", "--full-path" }):wait(300)
  if paths_result.code ~= 0 then
    vim.notify("Failed to get java paths", vim.log.levels.ERROR, { title = "Java" })
  else
    local javaPaths = vim.split(paths_result.stdout, "\n", { trimempty = true })
    -- vim.notify("Found " .. #javaPaths .. " java runtimes", vim.log.levels.DEBUG, { title = "Java" })
    for _, v in pairs(javaPaths) do
      local javaPath = path:new(v):parent():parent():absolute()
      M.runtimes[M.To_java_version_name(javaPath)] = javaPath
    end
  end
  -- vim.notify("Detected runtimes: " .. vim.inspect(M.runtimes), vim.log.levels.DEBUG, { title = "Java" })
else
  vim.notify("fd not found. Skipping java runtime detection", vim.log.levels.WARN, { title = "Java" })
end

M.filetypes = vim.g.java_filetypes
local java_root_config = vim.env.CUSTOM_JAVA_ROOTS
local java_roots = {}

if vim.fn.filereadable(java_root_config) == 1 then
  java_roots = vim.json.decode(table.concat(vim.fn.readfile(java_root_config), "\n"))
end

function M.javaRoot(fileName)
  local expanded_fname = vim.fn.expand(fileName)

  for _, v in pairs(java_roots) do
    local working_dir = vim.fn.expand(v.working_dir)
    if string.sub(expanded_fname, 1, string.len(working_dir)) == working_dir then
      return v.root
    end
  end
  return require("lspconfig.configs.jdtls").default_config.root_dir(fileName)
end

function M.has_runtimes()
  return not vim.tbl_isempty(M.runtimes)
end

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
function M.extend_or_override(config, custom, ...)
  if type(custom) == "function" then
    config = custom(config, ...) or config
  elseif custom then
    config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
  end
  return config
end

function M.runtimesAtleast(version)
  for i, v in pairs(M.runtimes) do
    if versionFromKey(i) >= version then
      return v
    end
  end
  error("Java runtime at least " .. version .. " not found")
end

function M.runtimesAt(version)
  for key, value in pairs(M.runtimes) do
    if versionFromKey(key) == version then
      return value
    end
  end
  error("Java runtime at " .. version .. " not found")
end

function M.execAt(version)
  return path:new(M.runtimesAt(version)):joinpath("bin", "java"):absolute()
end

function M.execAtleast(version)
  return path:new(M.runtimesAtleast(version)):joinpath("bin", "java"):absolute()
end

function M.runtimesConfig()
  local runtimesConfig = {}
  for i, v in pairs(M.runtimes) do
    local version = versionFromKey(i)
    if version == 8 then
      table.insert(runtimesConfig, { name = "JavaSE-1.8", path = v })
    else
      table.insert(runtimesConfig, { name = "JavaSE-" .. version, path = v })
    end
  end
  return runtimesConfig
end

return M
