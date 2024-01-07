return {
  "chrisgrieser/nvim-recorder",
  dependencies = "rcarriga/nvim-notify",
  keys = {
    -- these must match the keys in the mapping config below
    { "q", desc = " Start Recording" },
    { "Q", desc = " Play Recording" },
    { "W", desc = "  Switch Slot" },
    { "C", desc = "  Clear Macros" },
  },
  opts = function()
    require("recorder").setup({
      mapping = {
        startStopRecording = "q",
        playMacro = "Q",
        switchSlot = "W",
        deleteAllMacros = "C",
      },
    })
    local lualineX = require("lualine").get_config().sections.lualine_x or {}
    local lualineY = require("lualine").get_config().sections.lualine_y or {}
    table.insert(lualineX, { require("recorder").recordingStatus })
    table.insert(lualineY, { require("recorder").displaySlots })

    require("lualine").setup({
      sections = {
        lualine_x = lualineX,
        lualine_y = lualineY,
      },
    })
  end,
}
