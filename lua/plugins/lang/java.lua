local javaHelpers = require("modules.java")
local java_filetypes = javaHelpers.filetypes
local javaExec = javaHelpers.execAtleast(24)

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = java_filetypes,
    cond = javaHelpers.has_runtimes(),
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
          },
        },
      },
    },
    opts = function(_, opts)
      -- How to find the root dir for a given filename. The default comes from
      -- lspconfig which provides a function specifically for java projects.
      opts.root_dir = require("modules.java").javaRoot

      opts.jdtls = {
        settings = {
          java = {
            inlayHints = { parameterNames = { enabled = "all" } },
            configuration = {
              runtimes = javaHelpers.runtimesConfig(),
            },
          },
        },
      }
      opts.on_attach = function(args)
        require("which-key").add({
          "<leader>cj",
          icon = { icon = "", color = "orange" },
          buffer = args.buf,
          group = "jdtls",
          { "<leader>cjw", "<cmd>JdtWipeDataAndRestart<CR>", desc = "Wipe and Restart" },
          { "<leader>cjc", "<cmd>JdtCompile<CR>", desc = "Compile" },
          { "<leader>cjs", "<cmd>JdtSetRuntime<CR>", desc = "Set Runtime" },
          {
            "<leader>cju",
            rhs = function()
              require("jdtls").update_projects_config({ select_mode = "all" })
            end,
            desc = "Update Config",
          },
          { "<leader>cjr", "<cmd>JdtRestart<CR>", desc = "Restart" },
          { "<leader>cjj", "<cmd>JdtJshell<CR>", desc = "JShell" },
        })
      end
    end,
    config = function(_, opts)
      -- Find the extra bundles that should be passed on the jdtls command-line
      -- if nvim-dap is enabled with java debug/test.
      local bundles = {} ---@type string[]
      if LazyVim.has("mason.nvim") then
        local mason_registry = require("mason-registry")
        if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
          bundles = vim.fn.glob("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*jar", false, true)
          -- java-test also depends on java-debug-adapter.
          if opts.test and mason_registry.is_installed("java-test") then
            vim.list_extend(bundles, vim.fn.glob("$MASON/share/java-test/*.jar", false, true))
          end
        end

        -- spring boot support
        if LazyVim.has("spring-boot.nvim") and mason_registry.is_installed("vscode-spring-boot-tools") then
          vim.list_extend(bundles, require("spring_boot").java_extensions())
        end
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = javaHelpers.extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          settings = opts.settings,
          -- enable CMP capabilities
          capabilities = LazyVim.has("blink.cmp") and require("blink.cmp").get_lsp_capabilities() or LazyVim.has(
            "cmp-nvim-lsp"
          ) and require("cmp_nvim_lsp").default_capabilities() or nil,
        }, opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = java_filetypes,
        callback = attach_jdtls,
      })

      -- Setup keymap and dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      -- https://neovim.io/doc/user/lsp.html#LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require("which-key")
            wk.add({
              {
                mode = "n",
                buffer = args.buf,
                { "<leader>cx", group = "extract" },
                { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
                { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
                { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
                { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
                { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
              },
            })
            wk.add({
              {
                mode = "x",
                buffer = args.buf,
                { "<leader>cx", group = "extract" },
                {
                  "<leader>cxm",
                  [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                  desc = "Extract Method",
                },
                {
                  "<leader>cxv",
                  [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                  desc = "Extract Variable",
                },
                {
                  "<leader>cxc",
                  [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                  desc = "Extract Constant",
                },
              },
            })

            if LazyVim.has("mason.nvim") then
              local mason_registry = require("mason-registry")
              if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
                -- custom init for Java debugger
                require("jdtls").setup_dap(opts.dap)
                if opts.dap_main then
                  require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
                end

                -- Java Test require Java debugger to work
                if opts.test and mason_registry.is_installed("java-test") then
                  -- custom keymaps for Java test runner (not yet compatible with neotest)
                  wk.add({
                    {
                      mode = "n",
                      buffer = args.buf,
                      { "<leader>t", group = "test" },
                      {
                        "<leader>tt",
                        function()
                          require("jdtls.dap").test_class({
                            config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                          })
                        end,
                        desc = "Run All Test",
                      },
                      {
                        "<leader>tr",
                        function()
                          require("jdtls.dap").test_nearest_method({
                            config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                          })
                        end,
                        desc = "Run Nearest Test",
                      },
                      { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
                    },
                  })
                end
              end
            end

            -- User can set additional keymaps in opts.on_attach
            if opts.on_attach then
              opts.on_attach(args)
            end
          end
        end,
      })

      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      attach_jdtls()
    end,
  },
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    enabled = true,
    dependencies = {
      "mfussenegger/nvim-jdtls", -- or nvim-java, nvim-lspconfig
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "vscode-spring-boot-tools" })
        end,
      },
    },
    opts = {
      java_cmd = javaExec,
    },
  },
}
