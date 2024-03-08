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
    opts.jdtls = {
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.402.b06-1.fc39.x86_64/jre",
              },
              {
                name = "JavaSE-11",
                path = "/usr/lib/jvm/java-11-openjdk-11.0.22.0.7-1.fc39.x86_64/",
              },
              {
                name = "JavaSE-17",
                path = "/usr/lib/jvm/java-17-openjdk-17.0.9.0.9-3.fc39.x86_64/",
              },
              {
                name = "JavaSE-21",
                path = "/usr/lib/jvm/java-21-openjdk-21.0.2.0.13-1.fc39.x86_64/",
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
