local M = {}

function M.setup()
  require("dynamic-base16").set_colors({
    -- Background tones
    base00 = "{{colors.background.default.hex}}",
    base01 = "{{colors.surface_container_lowest.default.hex}}",
    base02 = "{{colors.surface_container_low.default.hex}}",
    base03 = "{{colors.outline_variant.default.hex}}",
    base04 = "{{colors.on_surface_variant.default.hex}}",
    base05 = "{{colors.on_surface.default.hex}}",
    base06 = "{{colors.inverse_on_surface.default.hex}}",
    base07 = "{{colors.surface_bright.default.hex}}",
    base08 = "{{colors.tertiary.default.hex | lighten: -5}}",
    base09 = "{{colors.tertiary.default.hex}}",
    base0A = "{{colors.secondary.default.hex}}",
    base0B = "{{colors.primary.default.hex}}",
    base0C = "{{colors.tertiary_container.default.hex}}",
    base0D = "{{colors.primary_container.default.hex}}",
    base0E = "{{colors.secondary_container.default.hex}}",
    base0F = "{{colors.secondary.default.hex | lighten: -10}}",
  })
  vim.api.nvim_set_hl(0, "Visual", {
    bg = "{{colors.primary_container.default.hex}}",
    fg = "{{colors.background.default.hex}}",
  })
  require("dynamic-base16").setup({
    transparent = true
  })
end

-- Register a signal handler for SIGUSR1 (matugen updates)
local signal = vim.uv.new_signal()
signal:start(
  "sigusr1",
  vim.schedule_wrap(function()
    package.loaded["matugen"] = nil
    require("matugen").setup()
  end)
)

return M
