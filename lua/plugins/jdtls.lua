local config_path = "/home/eslamallam/.config/nvim/jdtls-custom-roots.yaml"

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function readFile(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

local lyaml = require("lyaml")

local function expand_home(path)
  local home = os.getenv("HOME")
  if home == nil then
    return path
  end

  if string.sub(path, 1, 1) ~= "~" then
    return path
  end

  return home .. string.sub(path, 2, string.len(path))
end

local function user_configured_root_dir(fileName)
  local exists = file_exists(config_path)
  local expanded_fname = expand_home(fileName)
  if exists then
    local content = lyaml.load(readFile(config_path))

    for _, v in pairs(content) do
      local working_dir = expand_home(v.working_dir)
      if string.sub(expanded_fname, 1, string.len(working_dir)) == working_dir then
        return v.root
      end
    end

    return
  end
  return require("lspconfig.server_configurations.jdtls").default_config.root_dir(fileName)
end

return {
  "mfussenegger/nvim-jdtls",
  opts = function()
    return {
      -- How to find the root dir for a given filename. The default comes from
      -- lspconfig which provides a function specifically for java projects.
      root_dir = user_configured_root_dir,

      -- How to find the project name for a given root dir.
      project_name = function(root_dir)
        return root_dir and vim.fs.basename(root_dir)
      end,

      -- Where are the config and workspace dirs for a project?
      jdtls_config_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
      end,
      jdtls_workspace_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
      end,

      -- How to run jdtls. This can be overridden to a full java command-line
      -- if the Python wrapper script doesn't suffice.
      cmd = {
        vim.fn.exepath("jdtls"),
        "--jvm-arg=-javaagent:" .. os.getenv("MASON") .. "/packages/jdtls/lombok.jar",
      },

      jdtls = {
        init_options = {
          bundles = {
            vim.fn.glob(
              "/home/eslamallam/java-ext/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
              1
            ),
          },
        },
        settings = {
          java = {
            configuration = {
              runtimes = {
                {
                  name = "JavaSE-1.8",
                  path = "/usr/lib/jvm/java-1.8.0-openjdk-amd64/",
                },
                {
                  name = "JavaSE-11",
                  path = "/usr/lib/jvm/java-11-openjdk-amd64/",
                },
                {
                  name = "JavaSE-17",
                  path = "/usr/lib/jvm/java-17-openjdk-amd64/",
                },
                {
                  name = "JavaSE-21",
                  path = "/usr/lib/jvm/java-21-openjdk-amd64/",
                },
              },
            },
          },
        },
      },
      full_cmd = function(opts)
        local fname = vim.api.nvim_buf_get_name(0)
        local root_dir = opts.root_dir(fname)
        local project_name = opts.project_name(root_dir)
        local cmd = vim.deepcopy(opts.cmd)
        if project_name then
          vim.list_extend(cmd, {
            "-configuration",
            opts.jdtls_config_dir(project_name),
            "-data",
            opts.jdtls_workspace_dir(project_name),
          })
        end
        return cmd
      end,

      -- These depend on nvim-dap, but can additionally be disabled by setting false here.
      dap = { hotcodereplace = "auto", config_overrides = {} },
      test = true,
    }
  end,
}
