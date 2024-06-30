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

function M.get_file_size(file_path)
  local file = io.open(file_path, "r")
  if not file then return nil, "File not found" end
  local size = file:seek("end")
  file:close()
  return size
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

---check if any item matches condition
---@param items any[]
---@param predicate function 
function M.anyMatch(items, predicate)
  for _, v in ipairs(items) do
    if predicate(v) then
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

---perform hover but prioritize given lsp name
---@param name string
---@param ... elem_or_list<string> filetypes to apply this to
function M.hoverPrioritizeLsp(name, ...)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local clients = vim.lsp.get_clients({name = name, method = "textDocument/hover", bufnr = bufnr })
  for _, client in pairs(clients) do
    if ... == nil or M.contains({...}, filetype) then
      -- Use the hover method of the preferred client
      client.request("textDocument/hover", vim.lsp.util.make_position_params())
      return
    end
  end
  -- If the preferred client is not found, call the original hover function
  vim.lsp.buf.hover()
end

---@class excludedLsp
---@field name string
---@field filetypes string[]?

---perform hover but exclude given lsp names
---@param lsps excludedLsp[]
function M.hoverExcludeLsps(lsps)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local clients = vim.lsp.get_clients({ method = "textDocument/hover", bufnr = bufnr })
  for _, client in pairs(clients) do
    if
      not M.anyMatch(lsps, function(lsp)
        return lsp.name == client.name and (lsp.filetypes == nil or M.contains(lsp.filetypes, filetype))
      end)
    then
      -- Use the hover method of the preferred client
      client.request("textDocument/hover", vim.lsp.util.make_position_params())
      return
    end
  end
end

return M
