local javaHelpers = require("modules.java")
local java_filetypes = javaHelpers.filetypes
local javaExec = javaHelpers.execAtleast(17)

local cache_dir = vim.g.spring_cache_dir

return {
  {
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
                icon = { cat = "filetype", name = "java" },
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
  },
  {
    "eslam-allam/spring-boot.nvim",
    ft = "java",
    enabled = true,
    dependencies = {
      "mfussenegger/nvim-jdtls", -- or nvim-java, nvim-lspconfig
    },
    build = function(_)
      coroutine.yield("fetching latest release metadata")
      local release =
        vim.system({ "curl", "-s", "https://api.github.com/repos/spring-projects/sts4/releases/latest" }):wait()
      if release.code ~= 0 then
        error("failed to fetch latest spring_ls release: " .. release.stderr, vim.log.levels.ERROR)
      end
      local response_table = vim.json.decode(release.stdout, { luanil = { object = true, array = true } })
      local version_file = cache_dir .. "/version.txt"
      coroutine.yield("checking for existing installation")
      local latest_downloaded_version = nil
      if vim.fn.filereadable(version_file) == 1 then
        coroutine.yield("found previous installation, checking version")
        latest_downloaded_version = tonumber(vim.fn.readfile(version_file)[1])
      end

      coroutine.yield("finding target asset...")
      local download_link = nil
      local size = nil
      local latest_version = nil
      for _, asset in ipairs(response_table.assets) do
        if asset.browser_download_url then
          if type(asset.browser_download_url) == "string" and asset.browser_download_url:sub(-4) == "vsix" then
            download_link = asset.browser_download_url
            size = asset.size
            latest_version = asset.id
            break
          end
        end
      end

      if latest_downloaded_version ~= nil and latest_version == latest_downloaded_version then
        coroutine.yield("already at latest version")
        return
      end

      if download_link == nil then
        error("failed to get bundle link", vim.log.levels.ERROR)
      end
      coroutine.yield("downloading asset " .. download_link .. "...")
      local tmp_file = vim.fn.tempname()

      local output = {}
      local function on_output(error, line)
        if line ~= "" then
          vim.schedule(function()
            table.insert(output, line)
          end)
        end
      end
      local job_complete = false
      local job_code = 1
      local function on_exit(result)
        vim.schedule(function()
          job_complete = true
          job_code = result.code
        end)
      end
      local command = { "curl", "-L", "--progress-bar", "-o", tmp_file, download_link }
      vim.system(command, {
        stdout = on_output,
        stderr = on_output,
      }, on_exit)

      while not job_complete do
        vim.wait(10, function()
          return job_complete
        end)
        if vim.tbl_isempty(output) then
          coroutine.yield()
        else
          coroutine.yield({ msg = table.concat(output, ""), level = vim.log.levels.TRACE })
          output = {}
        end
      end

      coroutine.yield("download returned with code: " .. job_code)
      if job_code ~= 0 or vim.fn.filereadable(tmp_file) == 0 then
        error("failed to download asset", vim.log.levels.ERROR)
      end

      local downloaded_size = require("modules.helpers").get_file_size(tmp_file)
      if downloaded_size ~= size then
        error(
          "downloaded file size is incorrect. expected: " .. size .. ", recieved: " .. downloaded_size,
          vim.log.levels.ERROR
        )
      end

      coroutine.yield("unzipping asset " .. tmp_file)

      if vim.fn.isdirectory(cache_dir) == 1 then
        vim.fn.delete(cache_dir, "rf")
      end

      if vim.fn.mkdir(cache_dir, "p") ~= 1 then
        error("failed to create data dir.", vim.log.levels.ERROR)
      end

      local result = vim.system({ "unzip", tmp_file, "extension/*", "-d", cache_dir }):wait()
      coroutine.yield("deleting temporary file " .. tmp_file)
      if vim.fn.delete(tmp_file) ~= 0 then
        error("Warning: failed to delete tmp file", vim.log.levels.ERROR)
      end
      if result.code ~= 0 then
        error("failed to unzip asset", vim.log.levels.ERROR)
      end
      coroutine.yield("unpacking files from extension folder")

      vim.fn.system(table.concat({ "mv", cache_dir .. "/extension/*", cache_dir }, " "))

      coroutine.yield("deleting extension folder")
      if vim.fn.delete(cache_dir .. "/extension", "d") ~= 0 then
        error("failed to delete extension folder", vim.log.levels.ERROR)
      end

      coroutine.yield("saving version information")

      if vim.fn.writefile({ latest_version }, version_file) ~= 0 then
        error("failed to save version information", vim.log.levels.ERROR)
      end

      vim.notify("Succesfully built Spring-ls")
    end,
    config = function(_, opts)
      opts.ls_path = cache_dir .. "/language-server"
      opts.java_cmd = require("modules.java").execAt(17)
      opts.server = {
        root_dir = require("modules.java").javaRoot(vim.api.nvim_buf_get_name(0)),
        on_init = function(client)
          local rc = client.server_capabilities
          rc.inlayHintProvider = false
        end,
      }
      require("spring_boot").setup(opts)
    end,
  },
}
