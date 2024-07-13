return {
  "jackMort/ChatGPT.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
  event = "VeryLazy",
  config = function()
    local home = vim.fn.getenv("HOME")
    require("chatgpt").setup({
      api_key_cmd = "gpg --decrypt " .. home .. "/.secrets/open-ai-key.gpg",
      openai_params = {
        model = "gpt-4o",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 4096,
      },
    })
    require("which-key").add({
      "<leader>cg",
      group = "ChatGPT",
      icon = { icon = "󰁤", color = "green" },
      { "<leader>cgc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
      {
        mode = { "n", "v" },
        { "<leader>cga", "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
        {
          "<leader>cgd",
          "<cmd>ChatGPTRun docstring<CR>",
          desc = "Docstring",
          icon = { icon = "󰦨", color = "green" },
        },
        { "<leader>cge", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
        { "<leader>cgf", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
        { "<leader>cgg", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
        { "<leader>cgk", "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords" },
        { "<leader>cgl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
        { "<leader>cgo", "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
        { "<leader>cgr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
        { "<leader>cgs", "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize" },
        { "<leader>cgt", "<cmd>ChatGPTRun translate<CR>", desc = "Translate" },
        { "<leader>cgx", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
      },
    })
  end,
}
