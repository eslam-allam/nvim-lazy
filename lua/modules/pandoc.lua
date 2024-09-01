local M = {}

local base_command = {
  { "--variable", "geometry:margin=1in" },
  { "--variable", "mainfont:Times New Roman" },
  { "--variable", "monofont:JetBrainsMono Nerd Font Mono" },
  { "--variable", "fontsize=12pt" },
  { "--variable", "linkcolor:blue" },
  { "--variable", "geometry:a4paper" },
  { "--toc" },
  { "--variable", "toc-title:Table of Contents" },
  { "--variable", "toc-depth:5" },
  { "--pdf-engine", "xelatex" },
}
---Notify with pandoc prefix
---@param msg string
---@param lvl integer
local function notify(msg, lvl)
  vim.notify("[Pandoc] " .. msg, lvl)
end

---Notify info level
---@param msg string
local function info(msg)
  notify(msg, vim.log.levels.INFO)
end

---Notify warn level
---@param msg string
local function warn(msg)
  notify(msg, vim.log.levels.WARN)
end

---Notify error level
---@param msg string
local function error(msg)
  notify(msg, vim.log.levels.ERROR)
end

---@class pandoc.opts
---@field code_theme string theme used for code blocks

---@type pandoc.opts
local default_opts = {
  code_theme = "catppuccin",
}

---@param opts pandoc.opts
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", default_opts, opts or {})
  local pandoc_home = vim.fn.getenv("PANDOC_CONFIG")
  if not pandoc_home then
    warn("Pandoc home not defined. Functionality will be limited.")
    return
  end

  if vim.fn.isdirectory(pandoc_home) == 0 then
    error("Pandoc home defined but does not exist.")
    return
  end

  local header_directory = pandoc_home .. "/header"

  if vim.fn.isdirectory(header_directory) == 1 then
    local header_files = vim.fn.globpath(header_directory, "*.tex", false, true)
    for _, header in ipairs(header_files) do
      table.insert(base_command, { "--include-in-header", header })
    end
  end

  local theme_directory = pandoc_home .. "/themes"
  if vim.fn.isdirectory(theme_directory) == 1 then
    local theme_file = theme_directory .. "/" .. opts.code_theme .. ".theme"
    if vim.fn.filereadable(theme_file) then
      table.insert(base_command, { "--highlight-style", theme_file })
    else
      table.insert(base_command, { "--highlight-style", opts.code_theme })
    end
  end
end

---Return base command with extra args
---@param args table<string, any>?
---@return table
function M.command(args)
  local command = {}
  vim.list_extend(command, base_command)
  if args then
    for key, value in pairs(args) do
      table.insert(command, { key, value })
    end
  end
  return command
end

return M
