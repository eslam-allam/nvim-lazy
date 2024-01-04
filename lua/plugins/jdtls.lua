return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {
      setup = {
        jdtls = function(_, opts)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
              require("lazyvim.util").on_attach(function(_, buffer)
                vim.keymap.set(
                  "n",
                  "<leader>di",
                  "<Cmd>lua require'jdtls'.organize_imports()<CR>",
                  { buffer = buffer, desc = "Organize Imports" }
                )
                vim.keymap.set(
                  "n",
                  "<leader>dt",
                  "<Cmd>lua require'jdtls'.test_class()<CR>",
                  { buffer = buffer, desc = "Test Class" }
                )
                vim.keymap.set(
                  "n",
                  "<leader>dn",
                  "<Cmd>lua require'jdtls'.test_nearest_method()<CR>",
                  { buffer = buffer, desc = "Test Nearest Method" }
                )
                vim.keymap.set(
                  "v",
                  "<leader>de",
                  "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
                  { buffer = buffer, desc = "Extract Variable" }
                )
                vim.keymap.set(
                  "n",
                  "<leader>de",
                  "<Cmd>lua require('jdtls').extract_variable()<CR>",
                  { buffer = buffer, desc = "Extract Variable" }
                )
                vim.keymap.set(
                  "v",
                  "<leader>dm",
                  "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
                  { buffer = buffer, desc = "Extract Method" }
                )
                vim.keymap.set(
                  "n",
                  "<leader>cf",
                  "<cmd>lua vim.lsp.buf.formatting()<CR>",
                  { buffer = buffer, desc = "Format" }
                )
              end)

              local home = os.getenv("HOME")
              local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
              -- vim.lsp.set_log_level('DEBUG')
              local workspace_dir = home .. "/.cache/nvim/jdtls" .. project_name -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.

              local workspace_folder = home .. ".cache/nvim/jdtls/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
              local config = {
                -- The command that starts the language server
                -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
                cmd = {
                  "/usr/lib/jvm/java-17-openjdk-amd64/bin/java",
                  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                  "-Dosgi.bundles.defaultStartLevel=4",
                  "-Declipse.product=org.eclipse.jdt.ls.core.product",
                  "-Dlog.protocol=true",
                  "-Dlog.level=ALL",
                  "-Xmx4g",
                  "--add-modules=ALL-SYSTEM",
                  "--add-opens",
                  "java.base/java.util=ALL-UNNAMED",
                  "--add-opens",
                  "java.base/java.lang=ALL-UNNAMED",
                  -- If you use lombok, download the lombok jar and place it in ~/.local/share/eclipse
                  "-javaagent:" .. "/usr/share/java/jdtls/lombok-1.18.4.jar",

                  -- The jar file is located where jdtls was installed. This will need to be updated
                  -- to the location where you installed jdtls
                  "-jar",
                  vim.fn.glob("/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),

                  -- The configuration for jdtls is also placed where jdtls was installed. This will
                  -- need to be updated depending on your environment
                  "-configuration",
                  "/usr/share/java/jdtls/config_linux",

                  -- Use the workspace_folder defined above to store data for this project
                  "-data",
                  workspace_folder,
                },

                -- This is the default if not provided, you can remove it. Or adjust as needed.
                -- One dedicated LSP server & client will be started per unique root_dir
                root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

                -- Here you can configure eclipse.jdt.ls specific settings
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- for a list of options
                settings = {
                  java = {
                    format = {
                      settings = {
                        -- Use Google Java style guidelines for formatting
                        -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
                        -- and place it in the ~/.local/share/eclipse directory
                        url = "/.local/share/eclipse/eclipse-java-google-style.xml",
                        profile = "GoogleStyle",
                      },
                    },
                    signatureHelp = { enabled = true },
                    contentProvider = { preferred = "fernflower" }, -- Use fernflower to decompile library code
                    -- Specify any completion options
                    completion = {
                      favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*",
                      },
                      filteredTypes = {
                        "com.sun.*",
                        "io.micrometer.shaded.*",
                        "java.awt.*",
                        "jdk.*",
                        "sun.*",
                      },
                    },
                    -- Specify any options for organizing imports
                    sources = {
                      organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                      },
                    },
                    -- How code generation should act
                    codeGeneration = {
                      toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                      },
                      hashCodeEquals = {
                        useJava7Objects = true,
                      },
                      useBlocks = true,
                    },
                    -- If you are developing in projects with different Java versions, you need
                    -- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
                    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                    -- And search for `interface RuntimeOption`
                    -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
                    configuration = {
                      runtimes = {
                        {
                          name = "JavaSE-17",
                          path = "/usr/lib/jvm/java-17-openjdk-amd64",
                        },
                        {
                          name = "JavaSE-11",
                          path = "/usr/lib/jvm/java-11-openjdk-amd64",
                        },
                        {
                          name = "JavaSE-1.8",
                          path = "/usr/lib/jvm/java-1.8.0-openjdk-amd64",
                        },
                      },
                    },
                  },
                },
                handlers = {
                  ["language/status"] = function(_, result)
                    -- print(result)
                  end,
                  ["$/progress"] = function(_, result, ctx)
                    -- disable progress updates.
                  end,
                },
              }
              require("jdtls").start_or_attach(config)
            end,
          })
          return true
        end,
      },
    },
  },
}
