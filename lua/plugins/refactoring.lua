return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    {
      "<leader>rl",
      function()
        require("refactoring").select_refactor()
      end,
      desc = "Refactoring Options",
      mode = { "n", "x" },
    },
    {
      "<leader>rpf",
      function()
        require("refactoring").debug.printf({below = false})
      end,
      desc = "Print Function Call",
      mode = {"n"},
    },
{
      "<leader>rpv",
      function()
        require("refactoring").debug.print_var()
      end,
      desc = "Print Variable",
      mode = {"n", "x"},
    },
{
      "<leader>rpc",
      function()
        require("refactoring").debug.cleanup({})
      end,
      desc = "Clean Generated Prints",
      mode = {"n"},
    }
  },
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
