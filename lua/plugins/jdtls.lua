local javaHelpers = require("modules.java")
local java_filetypes = javaHelpers.filetypes
local javaExec = javaHelpers.execAtleast(17)

return {
  "mfussenegger/nvim-jdtls",
  ft = java_filetypes,
  dependencies = {
    "williamboman/mason.nvim",
  },
  opts = function(_, opts)
    -- How to find the root dir for a given filename. The default comes from
    -- lspconfig which provides a function specifically for java projects.
    opts.root_dir = require("modules.java").javaRoot

    local mason_home = vim.fn.getenv("MASON")
    local jdtls_base_path = mason_home .. "/packages/jdtls"
    local shared_config_path = jdtls_base_path .. "/config_linux"
    local plugins_dir = jdtls_base_path .. "/plugins"

    opts.cmd = {
      javaExec,
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
    local mason_registry = require("mason-registry")
    local bundles = {} ---@type string[]
    if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
      local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
      local java_dbg_path = java_dbg_pkg:get_install_path()
      local jar_patterns = {
        java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
      }
      -- java-test also depends on java-debug-adapter.
      if opts.test and mason_registry.is_installed("java-test") then
        local java_test_pkg = mason_registry.get_package("java-test")
        local java_test_path = java_test_pkg:get_install_path()
        vim.list_extend(jar_patterns, {
          java_test_path .. "/extension/server/*.jar",
        })
      end
      for _, jar_pattern in ipairs(jar_patterns) do
        for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
          table.insert(bundles, bundle)
        end
      end
    end

    -- spring boot support
    if LazyVim.has("spring-boot.nvim") then
      vim.list_extend(bundles, require("spring_boot").java_extensions(vim.g.spring_cache_dir .. "/jars"))
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

        -- enable CMP capabilities
        capabilities = LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities() or nil,
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
            "<leader>c",
            group = "code",
            buffer = args.buf,
            {
              "<leader>cx",
              group = "extract",
              icon = {cat = "filetype", name = "java"},
              {
                "<leader>cxm",
                mode = "x",
                rhs = function()
                  require("jdtls").extract_method({ visual = true })
                end,
                desc = "Extract Method",
              },
              {
                "<leader>cxv",
                rhs = function()
                  require("jdtls").extract_variable_all({ visual = false })
                end,
                desc = "Extract Variable",
              },
              {
                "<leader>cxc",
                rhs = function()
                  require("jdtls").extract_constant({ visual = false })
                end,
                desc = "Extract Constant",
              },
            },
            { "gs", rhs = require("jdtls").super_implementation, desc = "Goto Super" },
            { "gS", rhs = require("jdtls").goto_subjects, desc = "Goto Subjects" },
            { "<leader>co", rhs = require("jdtls").organize_imports, desc = "Organize Imports" },
          })

          if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
            -- custom init for Java debugger
            require("jdtls").setup_dap(opts.dap)
            require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)

            -- Java Test require Java debugger to work
            if opts.test and mason_registry.is_installed("java-test") then
              -- custom keymaps for Java test runner (not yet compatible with neotest)
              wk.add({
                "<leader>t",
                group = "test",
                buffer = args.buf,
                {
                  "<leader>tt",
                  rhs = function()
                    require("jdtls.dap").test_class({
                      config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                    })
                  end,
                  desc = "Run All test",
                },
                {
                  "<leader>tr",
                  rhs = function()
                    require("jdtls.dap").test_nearest_method({
                      config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                    })
                  end,
                  desc = "Run Nearest Test",
                },
                { "<leader>tT", rhs = require("jdtls.dap").pick_test, desc = "Run Test" },
              })
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
}
