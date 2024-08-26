return {
  "yetone/avante.nvim",
  cmd = { "AvanteAsk", "AvanteRefresh" },
  build = "make",
  init = function()
    require("which-key").add({
      "<localleader>a",
      desc = "Avante",
      icon = "",
      { "<localleader>aa", "<cmd>AvanteAsk<CR>", desc = "Ask Avant", icon = "󰺴", mode = { "n", "x" } },
      { "<localleader>ar", "<cmd>AvanteRefresh<CR>", desc = "Refresh Avante", icon = "" },
    })
  end,
  config = function(_, opts)
    vim.env.OPENAI_API_KEY = "ollama"
    require("avante").setup(opts)
    require("which-key").add({
      {
        "<localleader>ad",
        function()
          require("avante.config").debug = not require("avante.config").debug
        end,
        desc = "Toggle Debug",
      },
      {
        "<localleader>ah",
        function()
          require("avante.config").hint = not require("avante.config").hint
        end,
        desc = "Toggle Hint",
      },
    })
  end,
  opts = {
    hints = {
      enabled = false,
    },
    mappings = {
      ask = "<localleader>aa",
      edit = "<localleader>ac",
      refresh = "<localleader>ar",
    },
    toggle = {
      debug = "<localleader>ad",
      hint = "<localleader>ah",
    },
    -- add any opts here
    provider = "openai",
    openai = {
      endpoint = "http://127.0.0.1:11434/v1",
      model = "deepseek-coder-v2",
      temperature = 0,
      max_tokens = 1000000,
      ["local"] = true,
    },
  },
  dependencies = {
    "echasnovski/mini.icons",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      "MeanderingProgrammer/markdown.nvim",
      opts = {
        file_types = { "Avante" },
      },
      ft = { "markdown", "norg", "rmd", "org", "Avante" },
    },
  },
}
