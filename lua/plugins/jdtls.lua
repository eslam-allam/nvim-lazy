-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
local function extend_or_override(config, custom, ...)
  if type(custom) == "function" then
    config = custom(config, ...) or config
  elseif custom then
    config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
  end
  return config
end

local java_runtimes = vim.json.decode(table.concat(vim.fn.readfile(vim.env.JAVA_RUNTIMES_JSON), "\n"))
local java_root_config = vim.env.CUSTOM_JAVA_ROOTS
local java_roots = {}

if vim.fn.filereadable(java_root_config) == 1 then
  java_roots = vim.json.decode(table.concat(vim.fn.readfile(java_root_config), "\n"))
end

local java_filetypes = vim.g.java_filetypes

return {
  "mfussenegger/nvim-jdtls",
  ft = java_filetypes,
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
          u = {
            function()
              require("jdtls").update_projects_config({ select_mode = "all" })
            end,
            "Update Config",
          },
          r = { "<cmd>JdtRestart<CR>", "Restart" },
          j = { "<cmd>JdtJshell<CR>", "JShell" },
        },
      }, { mode = "n", prefix = "<leader>c", buffer = args.buf })
    end
  end,
  config = function()
    local opts = LazyVim.opts("nvim-jdtls") or {}

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

    local function attach_jdtls()
      local fname = vim.api.nvim_buf_get_name(0)

      -- Configuration can be augmented and overridden by opts.jdtls
      local config = extend_or_override({
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
          wk.register({
            ["<leader>cx"] = { name = "+extract" },
            ["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" },
            ["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" },
            ["gs"] = { require("jdtls").super_implementation, "Goto Super" },
            ["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" },
            ["<leader>co"] = { require("jdtls").organize_imports, "Organize Imports" },
          }, { mode = "n", buffer = args.buf })
          wk.register({
            ["<leader>c"] = { name = "+code" },
            ["<leader>cx"] = { name = "+extract" },
            ["<leader>cxm"] = {
              [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
              "Extract Method",
            },
            ["<leader>cxv"] = {
              [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
              "Extract Variable",
            },
            ["<leader>cxc"] = {
              [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
              "Extract Constant",
            },
          }, { mode = "v", buffer = args.buf })

          if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
            -- custom init for Java debugger
            require("jdtls").setup_dap(opts.dap)
            require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)

            -- Java Test require Java debugger to work
            if opts.test and mason_registry.is_installed("java-test") then
              -- custom keymaps for Java test runner (not yet compatible with neotest)
              wk.register({
                ["<leader>t"] = { name = "+test" },
                ["<leader>tt"] = { require("jdtls.dap").test_class, "Run All Test" },
                ["<leader>tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" },
                ["<leader>tT"] = { require("jdtls.dap").pick_test, "Run Test" },
              }, { mode = "n", buffer = args.buf })
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
