return {
  {
    "nvchad/minty",
    lazy = true,
    dependencies = {
      { "nvchad/volt", lazy = true },
    },
    init = function()
      require("which-key").add({
        "<localleader>c",
        group = "Color",
        {
          "<localleader>cp",
          group = "Picker",
          {
            "<localleader>cph",
            function()
              require("minty.huefy").open()
            end,
            desc = "Pick Hue",
          },
          {
            "<localleader>cps",
            function()
              require("minty.shades").open()
            end,
            desc = "Pick Shade",
          },
        },
      })
    end,
  },
}
