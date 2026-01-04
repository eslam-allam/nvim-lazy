return {

  "nvim-java/nvim-java",

  dependencies = {
    "mason-org/mason.nvim",
    {
      "neovim/nvim-lspconfig",
      ---@class PluginLspOpts
      opts = {
        inlay_hints = {
          exclude = { "java" },
        },
        servers = {
          --- @type vim.lsp.Config
          kotlin_language_server = {
            cmd_env = { JAVA_HOME = require("modules.java").runtimesAt(17) },
          },
          --- @type vim.lsp.Config
          gradle_ls = {
            name = "gradle_ls",
            filetypes = { "groovy" },
            root_markers = { "settings.gradle", { "build.gradle", "build.gradle.kts" }, "gradlew", "gradle.war" },
            cmd_env = { JAVA_HOME = require("modules.java").runtimesAtleast(17) },
          },
          --- @type vim.lsp.Config
          jdtls = {
            cmd_env = { JAVA_HOME = require("modules.java").runtimesAtleast(17) },
            settings = {
              java = {
                signatureHelp = { enabled = true },
                configuration = {
                  runtimes = require("modules.java").runtimesConfig(),
                },
              },
            },
            on_attach = function(client, bufnr)
              local wk = require("which-key")
              wk.add({
                {
                  mode = "n",
                  buffer = bufnr,
                  { "<leader>cx", group = "extract" },
                  { "<leader>cxv", require("java").refactor.extract_variable, desc = "Extract Variable" },
                  {
                    "<leader>cxV",
                    require("java").refactor.extract_variable_all_occurrence,
                    desc = "Extract Variable (All Occurrences)",
                  },
                  { "<leader>cxc", require("java").refactor.extract_constant, desc = "Extract Constant" },
                  { "<leader>cxf", require("java").refactor.extract_field, desc = "Extract Field" },
                  { "<leader>cxm", require("java").refactor.extract_method, desc = "Extract Method" },

                  { "<leader>cjb", group = "build" },
                  { "<leader>cjbb", require("java").build.build_workspace, desc = "Build Workspace" },
                  { "<leader>cjbc", require("java").build.clean_workspace, desc = "Clean Workspace" },

                  { "<leader>cj", group = "Java" },
                  { "<leader>cjr", group = "Run" },
                  {
                    "<leader>cjrr",
                    function()
                      require("java").runner.built_in.run_app({})
                    end,
                    desc = "Run Main",
                  },
                  { "<leader>cjrs", require("java").runner.built_in.stop_app, desc = "Stop App" },
                  { "<leader>cjrl", require("java").runner.built_in.toggle_logs, desc = "Toggle Logs" },

                  { "<leader>cjt", group = "Test" },
                  { "<leader>cjtr", require("java").test.run_current_class, desc = "Run Current Class" },
                  { "<leader>cjtR", require("java").test.debug_current_class, desc = "Debug Current Class" },
                  { "<leader>cjtm", require("java").test.run_current_method, desc = "Run Current Method" },
                  { "<leader>cjtM", require("java").test.run_current_method, desc = "Debug Current Method" },
                  { "<leader>cjtv", require("java").test.view_last_report, desc = "View Last Report" },

                  { "<leader>cjs", group = "Settings" },
                  { "<leader>cjsp", require("java").profile.ui, desc = "Open Profiles UI" },
                  { "<leader>cjsr", require("java").settings.change_runtime, desc = "Change Runtime" },
                },
              })
            end,
          },
        },
      },
    },
  },
  config = function()
    require("java").setup()
    vim.lsp.enable("jdtls")
  end,
  opts = {
    -- JDK installation
    jdk = {
      auto_install = false,
    },
  },
}
