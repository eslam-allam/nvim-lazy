return {
  {
    "monaqa/dial.nvim",
    keys = function()
      ---@param increment boolean
      ---@param g? boolean
      local function dial(increment, g)
        local mode = vim.fn.mode(true)
        -- Use visual commands for VISUAL 'v', VISUAL LINE 'V' and VISUAL BLOCK '\22'
        local is_visual = mode == "v" or mode == "V" or mode == "\22"
        local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
        local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
        return require("dial.map")[func](group)
      end
      return {
        -- stylua: ignore
        { "<C-g>", function() return dial(true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
        -- stylua: ignore
        { "<C-x>", function() return dial(false) end, expr = true, desc = "Decrement", mode = {"n", "v"} },
        -- stylua: ignore
        { "g<C-g>", function() return dial(true, true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
        -- stylua: ignore
        { "g<C-x>", function() return dial(false, true) end, expr = true, desc = "Decrement", mode = {"n", "v"} },
      }
    end,
  },
  {
    "stevearc/dressing.nvim",
    -- Don't replace vim.ui.select
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "Chaitanyabsprip/fastaction.nvim",
    config = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = require("fastaction").select
    end,
  },
}
