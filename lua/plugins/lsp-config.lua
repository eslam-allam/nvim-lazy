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
    opts = function(_, opts)
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "K",
        function()
          require("modules.helpers").hoverExcludeLsps(vim.g.hover_exclude_lsps)
        end,
      }
      -- make sure mason installs the server
      opts.servers.gradle_ls = {}
      opts.setup.gradle_ls = function(_, optss)
        optss.root_dir = require("modules.java").javaRoot
      end
    end,
  },
}
