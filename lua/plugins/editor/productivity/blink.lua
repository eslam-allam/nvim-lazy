return {
  "saghen/blink.cmp",
  optional = true,
  opts = {
    enabled = function()
      if vim.g.cmp_file_disabled == nil then
        return true
      end
      for _, type in ipairs(vim.g.cmp_file_disabled) do
        if type == vim.bo.filetype then
          return false
        end
      end
      return true
    end
  }
}
