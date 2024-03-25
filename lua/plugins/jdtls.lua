local java_runtimes = vim.json.decode(table.concat(vim.fn.readfile(vim.env.JAVA_RUNTIMES_JSON), "\n"))
local java_root_config = vim.env.CUSTOM_JAVA_ROOTS
local java_roots = {}

if vim.fn.filereadable(java_root_config) == 1 then
  java_roots = vim.json.decode(table.concat(vim.fn.readfile(java_root_config), "\n"))
end

return {
  "mfussenegger/nvim-jdtls",

  opts = function(_, opts)
    -- How to find the root dir for a given filename. The default comes from
    -- lspconfig which provides a function specifically for java projects.
    opts.root_dir = function(fileName)
      local expanded_fname = vim.fn.expand(fileName)

      for _, v in pairs(java_roots) do
        local working_dir = vim.fn.expand(v.working_dir)
        if string.sub(expanded_fname, 1, string.len(working_dir)) == working_dir then
          return v.root
        end
      end
      return require("lspconfig.server_configurations.jdtls").default_config.root_dir(fileName)
    end

    local mason_home = vim.fn.getenv("MASON")
    local jdtls_base_path = mason_home .. "/packages/jdtls"
    local shared_config_path = jdtls_base_path .. "/config_linux"
    local plugins_dir = jdtls_base_path .. "/plugins"

    opts.cmd = {
      java_runtimes.java21 .. "/bin/java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dosgi.checkConfiguration=true",
      "-Dosgi.sharedConfiguration.area=" .. shared_config_path,
      "-Dosgi.sharedConfiguration.area.readOnly=true",
      "-Dosgi.configuration.cascaded=true",
      "-Xms1G",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-javaagent:" .. mason_home .. "/packages/jdtls/lombok.jar",
      "-jar",
      vim.fn.glob(plugins_dir .. "/org.eclipse.equinox.launcher_*.jar"),
    }

    opts.jdtls = {
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = java_runtimes.java8,
              },
              {
                name = "JavaSE-11",
                path = java_runtimes.java11,
              },
              {
                name = "JavaSE-17",
                path = java_runtimes.java17,
              },
              {
                name = "JavaSE-21",
                path = java_runtimes.java21,
              },
            },
          },
        },
      },
    }
    opts.on_attach = function(args)
      require("which-key").register({
        j = {
          name = "jdtls",
          w = { "<cmd>JdtWipeDataAndRestart<CR>", "Wipe and Restart" },
          c = { "<cmd>JdtCompile<CR>", "Compile" },
          s = { "<cmd>JdtSetRuntime<CR>", "Set Runtime" },
          u = { "<cmd>JdtUpdateConfig<CR>", "Update Config" },
          r = { "<cmd>JdtRestart<CR>", "Restart" },
          j = { "<cmd>JdtJshell<CR>", "JShell" },
        },
      }, { mode = "n", prefix = "<leader>c", buffer = args.buf })
    end
  end,
}
