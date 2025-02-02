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
            local check_is_image = function(fileName)
              local image_extensions = { "png", "jpg", "webp" } -- Supported image formats
              local split_path = vim.split(fileName:lower(), ".", { plain = true })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end

            local fileName = ctx.item.file

            local bufnr = ctx.preview.win.buf
            local cwd = ctx.item.cwd

            -- Clear previous image
            if ctx.prev ~= nil then
              local prev_image = images[require("plenary.path"):new(ctx.prev.cwd):joinpath(ctx.prev.file):absolute()]

              if prev_image then
                prev_image:clear(true)
              end
            end

            -- Fallback to the default implementation if the file is not an image or we don't have image.nvim
            if not check_is_image(fileName) or not LazyVim.has("image.nvim") then
              return require("snacks").picker.preview.file(ctx)
            end

            -- Remove the content from the previous preview
            ctx.preview:set_lines({})

            local filepath = require("plenary.path"):new(cwd):joinpath(fileName):absolute()
            local autocmd

            -- Clear used memory and the images array when the picker is closed
            autocmd = vim.api.nvim_create_autocmd("WinClosed", {
              callback = function(evt)
                if ctx.picker.closed then
                  for _, i in ipairs(images) do
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

            local image = images[filepath]

            if image then
              image:render()
              return
            end

            image = require("image").from_file(filepath, {
              window = ctx.win,
              buffer = bufnr,
              width = vim.api.nvim_win_get_width(ctx.win),
              with_virtual_padding = true,
            })

            images[filepath] = image

            if not image then
              return
            end
            image:render()
          end,
        },
      },
    },
  },
}
