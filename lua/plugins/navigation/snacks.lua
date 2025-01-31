---@type table<string, Image>
local images = {}

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
        },
        files = {

          ---@param ctx snacks.picker.preview.ctx
          preview = function(ctx)
            local uv = vim.uv

            local bufnr = ctx.preview.win.buf
            local fileName = ctx.item.file
            local cwd = ctx.item.cwd

            if ctx.item.buf and not ctx.item.file and not vim.api.nvim_buf_is_valid(ctx.item.buf) then
              ctx.preview:notify("Buffer no longer exists", "error")
              return
            end

            -- used by some LSP servers that load buffers with custom URIs
            if ctx.item.buf and vim.uri_from_bufnr(ctx.item.buf):sub(1, 4) ~= "file" then
              vim.fn.bufload(ctx.item.buf)
            end

            if ctx.item.buf and vim.api.nvim_buf_is_loaded(ctx.item.buf) then
              local name = vim.api.nvim_buf_get_name(ctx.item.buf)
              name = uv.fs_stat(name) and vim.fn.fnamemodify(name, ":t") or name
              ctx.preview:set_title(name)
              vim.api.nvim_win_set_buf(ctx.win, ctx.item.buf)
            else
              local path = Snacks.picker.util.path(ctx.item)
              if not path then
                ctx.preview:notify("Item has no `file`", "error")
                return
              end
              -- re-use existing preview when path is the same
              if path ~= Snacks.picker.util.path(ctx.prev) then
                ctx.preview:reset()
                vim.bo[ctx.buf].buftype = ""

                local name = vim.fn.fnamemodify(path, ":t")
                ctx.preview:set_title(ctx.item.title or name)

                local stat = uv.fs_stat(path)
                if not stat then
                  ctx.preview:notify("file not found: " .. path, "error")
                  return false
                end
                if stat.type == "directory" then
                  return require("snacks.picker.preview").directory(ctx)
                end
                local max_size = ctx.picker.opts.previewers.file.max_size or (1024 * 1024)
                if stat.size > max_size then
                  ctx.preview:notify("large file > 1MB", "warn")
                  return false
                end
                if stat.size == 0 then
                  ctx.preview:notify("empty file", "warn")
                  return false
                end

                local file = assert(io.open(path, "r"))

                local is_binary = false
                local ft = ctx.picker.opts.previewers.file.ft or vim.filetype.match({ filename = path })
                if ft == "bigfile" then
                  ft = nil
                end

                local check_is_image = function(fileName)
                  local image_extensions = { "png", "jpg", "webp" } -- Supported image formats
                  local split_path = vim.split(fileName:lower(), ".", { plain = true })
                  local extension = split_path[#split_path]
                  return vim.tbl_contains(image_extensions, extension)
                end

                local is_image = check_is_image(fileName)

                local lines = {}
                if not is_image then
                  for line in file:lines() do
                    ---@cast line string
                    if #line > ctx.picker.opts.previewers.file.max_line_length then
                      line = line:sub(1, ctx.picker.opts.previewers.file.max_line_length) .. "..."
                    end
                    -- Check for binary data in the current line
                    if line:find("[%z\1-\8\11\12\14-\31]") then
                      is_binary = true
                      if not ft then
                        ctx.preview:notify("binary file", "warn")
                        return
                      end
                    end
                    table.insert(lines, line)
                  end
                end

                file:close()

                local winid = ctx.preview.win.win

                if ctx.prev ~= nil then
                  local prev_image =
                    images[require("plenary.path"):new(ctx.prev.cwd):joinpath(ctx.prev.file):absolute()]

                  if prev_image then
                    prev_image:clear(true)
                  end
                end

                local filepath = require("plenary.path"):new(cwd):joinpath(fileName):absolute()
                if is_image and LazyVim.has("image.nvim") then
                  local autocmd
                  autocmd = vim.api.nvim_create_autocmd("WinClosed", {
                    callback = function(evt)
                      if evt.match ~= winid then
                        for _, i in ipairs(images) do
                          i:clear(false)
                        end
                        images = {}
                        if autocmd ~= nil then
                          vim.api.nvim_del_autocmd(autocmd)
                        end
                      end
                    end,
                  })

                  local image = images[filepath]

                  if image then
                    image:render()
                    return
                  end

                  image = require("image").from_file(filepath, {
                    window = winid,
                    buffer = bufnr,
                    width = vim.api.nvim_win_get_width(winid),
                    with_virtual_padding = true,
                  })

                  images[filepath] = image

                  if not image then
                    return
                  end
                  image:render()
                  return
                elseif is_binary then
                  ctx.preview:wo({ number = false, relativenumber = false, cursorline = false, signcolumn = "no" })
                end
                ctx.preview:set_lines(lines)
                ctx.preview:highlight({ file = path, ft = ctx.picker.opts.previewers.file.ft, buf = ctx.buf })
              end
            end
            ctx.preview:loc()
          end,
        },
      },
    },
  },
}
