local helpers = require("modules.helpers")
vim.lsp.util.apply_text_document_edit = function(text_document_edit, index, offset_encoding)
  local text_document = text_document_edit.textDocument
  local bufnr = vim.uri_to_bufnr(text_document.uri)
  if offset_encoding == nil then
    vim.notify_once("apply_text_document_edit must be called with valid offset encoding", vim.log.levels.WARN)
  end

  vim.lsp.util.apply_text_edits(text_document_edit.edits, bufnr, offset_encoding)
end
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        gradle_ls = {},
      },
      setup = {
        gradle_ls = function(_, opts)
          opts.root_dir = require("modules.java").javaRoot
        end,
        html = function(_, opts)
          if opts.filetypes == nil then
            opts.filetypes = { "html" }
          elseif vim.tbl_contains(opts.filetypes, "templ") then
            helpers.remove_value(opts.filetypes, "templ")
          end
        end,
      },
    },
  },
}
