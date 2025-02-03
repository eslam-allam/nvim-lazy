---@type table<string, Image>
local images = {}

---@param filepath string
---@param ctx snacks.picker.preview.ctx
local function render_image_nvim(filepath, ctx)
  local image = images[filepath]

  if image then
    image:render()
    return true
  end

  local loaded_image = require("image").from_file(filepath, {
    window = ctx.win,
    buffer = ctx.buf,
    width = vim.api.nvim_win_get_width(ctx.win),
    with_virtual_padding = true,
  })

  if not loaded_image then
    error("Could not render image")
  end

  images[filepath] = loaded_image

  loaded_image:render()
end

---@param cwd string
---@param filename string
---@return string
local function getFullPath(cwd, filename)
  local path = require("plenary.path")

  local filePath = path:new(filename)
  if filePath:is_absolute() then
    return filePath:absolute()
  end

  return path:new(cwd):joinpath(filename):absolute()
end

---@param ctx snacks.picker.preview.ctx
local function preview_file(ctx)
  local check_is_image = function(fileName)
    local image_extensions = { "png", "jpg", "webp" } -- Supported image formats
    local split_path = vim.split(fileName:lower(), ".", { plain = true })
    local extension = split_path[#split_path]
    return vim.tbl_contains(image_extensions, extension)
  end

  local fileName = ctx.item.file

  local cwd = ctx.item.cwd

  -- Clear previous image
  if ctx.prev ~= nil then
    local prev_path = getFullPath(ctx.prev.cwd, ctx.prev.file)
    local prev_image = images[prev_path]

    if prev_image then
      prev_image:clear(prev_image.is_chafa ~= nil)
    end
  end

  local has_image_nvim = LazyVim.has("image.nvim")
  local has_chafa = vim.fn.executable("chafa") == 1
  -- Fallback to the default implementation if the file is not an image or we don't have image.nvim
  if not check_is_image(fileName) or not (has_image_nvim or has_chafa) then
    return require("snacks").picker.preview.file(ctx)
  end

  -- Remove the content from the previous preview
  ctx.preview:set_lines({})

  local filepath = getFullPath(cwd, fileName)

  local autocmd

  -- Clear used memory and the images array when the picker is closed
  autocmd = vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(evt)
      if ctx.picker.closed or not ctx.picker.shown then
        for _, i in pairs(images) do
          i:clear(false)
        end
        images = {}

        -- Remove the autocmd since we don't need it anymore
        if autocmd ~= nil then
          vim.api.nvim_del_autocmd(autocmd)
        end
      end
    end,
  })

  if has_image_nvim then
    return render_image_nvim(filepath, ctx)
  end

  if has_chafa then
    local opts = {
      relative = "win", -- Make it relative to the current window
      win = ctx.win,
      width = vim.api.nvim_win_get_width(ctx.win),
      height = vim.api.nvim_win_get_height(ctx.win),
      col = 0,
      row = 0,
      style = "minimal",
      border = "none", -- Change to "none" if you want it to blend in
      zindex = 51,
    }
    local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer
    local termwin = vim.api.nvim_open_win(buf, false, opts)
    local Image = {}
    Image.__index = Image

    function Image:new(buf, win)
      return setmetatable({ __buf = buf, __win = win, is_chafa = true }, self)
    end

    function Image:clear(shallow)
      if shallow then
        vim.api.nvim_win_hide(self.__win)
      else
        vim.api.nvim_buf_delete(self.__buf, { force = true })
      end
    end
    function Image:render()
      self.__win = vim.api.nvim_open_win(buf, false, opts)
    end

    images[filepath] = Image:new(buf, termwin)
    local term = vim.api.nvim_open_term(buf, {})
    local function send_output(_, data, _)
      for _, d in ipairs(data) do
        vim.api.nvim_chan_send(term, d .. "\r\n")
      end
    end

    vim.fn.jobstart({
      "chafa",
      "-f",
      "symbols",
      "--view-size",
      tostring(vim.api.nvim_win_get_width(ctx.win)) .. "x" .. tostring(vim.api.nvim_win_get_height(ctx.win)),
      filepath, -- Terminal image viewer command
    }, { on_stdout = send_output, stdout_buffered = true, pty = true })
  end
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    picker = {
      sources = {
        explorer = {
          layout = { preset = "default", preview = true },
          auto_close = true,
          preview = preview_file,
        },
        files = {
          preview = preview_file,
        },
      },
    },
  },
}
