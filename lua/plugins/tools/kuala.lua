return {
  "mistweaverco/kulala.nvim",
  optional = true,
  keys = function()
    return {}
  end,
  init = function()
    require("which-key").add({
      "<leader>R",
      desc = "Rest",
      icon = { cat = "filetype", name = "http" },
      {
        "<leader>Rc",
        function()
          require("kulala").close()
        end,
        desc = "Close Window",
        icon = { icon = "󰆴", color = "red" },
      },
      {
        "<leader>Rt",
        function()
          require("kulala").scratchpad()
        end,
        desc = "Open Scra[t]chpad",
        icon = { icon = "󰎚", color = "yellow" },
      },
      {
        "<leader>Re",
        function()
          require("kulala").set_selected_env()
        end,
        desc = "Set Env",
        icon = { cat = "filetype", name = "dotenv" },
      },
      {
        "<leader>RS",
        function()
          require("kulala").search()
        end,
        desc = "Find Files",
        icon = { icon = "", color = "green" },
      },
      {
        "<leader>Rn",
        function()
          require("kulala").jump_next()
        end,
        desc = "Jump to next request",
        icon = { icon = "󰈑", color = "yellow" },
      },
      {
        "<leader>Rp",
        function()
          require("kulala").jump_prev()
        end,
        desc = "Jump to previous request",
        icon = { icon = "", color = "yellow" },
      },
      {
        "<leader>Rs",
        function()
          require("kulala").run()
        end,
        desc = "Send the request",
        icon = { icon = "", color = "green" },
      },
      {
        "<leader>Rv",
        function()
          require("kulala").toggle_view()
        end,
        desc = "Toggle View",
        icon = { icon = "", color = "orange" },
      },
    })
  end,
  opts = {
    ui = {
      formatter = true
    }
  }
}
