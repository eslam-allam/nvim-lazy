return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  init = function()
    local wk = require("which-key")
    wk.register({
      r = {
        name = "refactor",
        l = {
          function()
            require("refactoring").select_refactor({ show_success_message = false })
          end,
          "Refactoring Options",
          mode = { "n", "v" },
        },
        p = {
          name = "print",
          f = {
            function()
              require("refactoring").debug.printf({ below = false, show_success_message = false })
            end,
            "Print Function Call",
          },
          v = {
            function()
              require("refactoring").debug.print_var({ show_success_message = false })
            end,
            "Print Variable",
          },
          c = {
            function()
              require("refactoring").debug.cleanup({ show_success_message = false })
            end,
            "Clean Generated Prints",
          },
        },
      },
    }, { prefix = "<leader>" })
  end,
  opts = {
    prompt_func_return_type = {
      go = true,
      cpp = true,
      c = true,
      java = true,
    },
    -- prompt for function parameters
    prompt_func_param_type = {
      go = true,
      cpp = true,
      c = true,
      java = true,
    },
  },
}
