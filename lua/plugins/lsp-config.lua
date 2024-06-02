vim.lsp.util.apply_text_document_edit = function(text_document_edit, index, offset_encoding)
    local text_document = text_document_edit.textDocument
    local bufnr = vim.uri_to_bufnr(text_document.uri)
    if offset_encoding == nil then
        vim.notify_once('apply_text_document_edit must be called with valid offset encoding', vim.log.levels.WARN)
    end

    vim.lsp.util.apply_text_edits(text_document_edit.edits, bufnr, offset_encoding)
end
return {
  {
    "neovim/nvim-lspconfig",
    init = function ()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys+1] = {"gr", "<cmd>lua require('telescope.builtin').lsp_references({})<cr>"}
    end,
    opts = {
      -- make sure mason installs the server
      servers = {
        gradle_ls = {},
      },
      setup = {
        gradle_ls = function(_, opts)
          opts.root_dir = require("modules.java").javaRoot
        end,
      },
    },
  },
}
