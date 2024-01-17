return {
  "chrisgrieser/nvim-recorder",
  dependencies = "rcarriga/nvim-notify",
  keys = {
    -- these must match the keys in the mapping config below
    { "q", desc = " Start Recording" },
    { "Q", desc = " Play Recording" },
    { "<C-q>", desc = "  Switch Slot" },
    { "cq", desc = "  Edit Macro" },
    { "yq", desc = "  Yank Macro" },
    { "dq", desc = "  Clear Macros" },
  },
  opts = {
      slots = { "a", "b", "c", "d" },
      mapping = {
        startStopRecording = "q",
        playMacro = "Q",
        switchSlot = "<C-q>",
        editMacro = "cq",
        deleteAllMacros = "dq",
        yankMacro = "yq",
        -- ⚠️ this should be a string you don't use in insert mode during a macro
        addBreakPoint = "##",
      },
      -- Clears all macros-slots on startup.
      clear = false,

      -- Log level used for any notification, mostly relevant for nvim-notify.
      -- (Note that by default, nvim-notify does not show the levels `trace` & `debug`.)
      logLevel = vim.log.levels.INFO,

      -- If enabled, only critical notifications are sent.
      -- If you do not use a plugin like nvim-notify, set this to `true`
      -- to remove otherwise annoying messages.
      lessNotifications = false,

      -- Use nerdfont icons in the status bar components and keymap descriptions
      useNerdfontIcons = true,

      -- Performance optimzations for macros with high count. When `playMacro` is
      -- triggered with a count higher than the threshold, nvim-recorder
      -- temporarily changes changes some settings for the duration of the macro.
      performanceOpts = {
        countThreshold = 100,
        lazyredraw = true, -- enable lazyredraw (see `:h lazyredraw`)
        noSystemClipboard = true, -- remove `+`/`*` from clipboard option
        autocmdEventsIgnore = { -- temporarily ignore these autocmd events
          "TextChangedI",
          "TextChanged",
          "InsertLeave",
          "InsertEnter",
          "InsertCharPre",
        },
      },
      -- [experimental] partially share keymaps with nvim-dap.
      -- (See README for further explanations.)
      dapSharedKeymaps = false,
  },
}
