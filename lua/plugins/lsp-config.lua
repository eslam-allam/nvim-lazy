local java_root_config = vim.env.CUSTOM_JAVA_ROOTS
local java_roots = {}

if vim.fn.filereadable(java_root_config) == 1 then
  java_roots = vim.json.decode(table.concat(vim.fn.readfile(java_root_config), "\n"))
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
          opts.root_dir = function(fileName)
            local expanded_fname = vim.fn.expand(fileName)

            for _, v in pairs(java_roots) do
              local working_dir = vim.fn.expand(v.working_dir)
              if string.sub(expanded_fname, 1, string.len(working_dir)) == working_dir then
                return v.root
              end
            end
            return require("lspconfig.server_configurations.gradle_ls").default_config.root_dir(fileName)
          end
        end,
      },
    },
  },
}
