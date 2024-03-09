local helpers = require("config.helpers")

return {
  "mfussenegger/nvim-jdtls",

  filetype = { "java", "groovy" },

  opts = function(_, opts)
    -- How to find the root dir for a given filename. The default comes from
    -- lspconfig which provides a function specifically for java projects.
    opts.root_dir = helpers.User_configured_root_dir

    -- Where are the config and workspace dirs for a project?
    opts.cmd = {
      "/home/eslamallam/.config/nvim/jdtls-bin/jdtls",
      "--jvm-arg=-javaagent:" .. os.getenv("MASON") .. "/packages/jdtls/lombok.jar",
    }

    local java_runtimes = vim.json.decode(helpers.ReadFile(vim.env.JAVA_RUNTIMES_JSON))
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
