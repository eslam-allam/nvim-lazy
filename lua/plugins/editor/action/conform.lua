return {
  "stevearc/conform.nvim",
  build = function()
    local path = require("plenary.path")

    if vim.fn.isdirectory(vim.g.custom_formater_exec_folder) == 0 then
      coroutine.yield("Creating custom formatter exec folder")
      if vim.fn.mkdir(vim.g.custom_formater_exec_folder, "p") == 0 then
        coroutine.yield({ msg = "Failed to create custom formatter exec folder", level = vim.log.levels.ERROR })
        return false
      end
    end

    coroutine.yield("Finding google-java-format installation")
    local java_formatter_jar_dir = require("mason-registry").get_package("google-java-format"):get_install_path()
    local java_formatter_jar =
        vim.fn.glob(path:new(java_formatter_jar_dir):joinpath("google-java-format-*.jar"):absolute())
    if java_formatter_jar == "" then
      coroutine.yield({ msg = "Google java formatter not found!", level = vim.log.levels.WARN })
      return false
    end

    local java_exec = require("modules.java").execAtleast(11)
    local commands = {}
    local is_linux = vim.fn.has("linux") == 1
    local exec_file_name = "google-java-format"

    if is_linux then
      table.insert(commands, { "#!/usr/bin/env bash", "" })
      table.insert(commands, { "exec", java_exec, "-jar", '"' .. java_formatter_jar .. '"', '"$@"' })
    else
      exec_file_name = "google-java-format.cmd"
      table.insert(commands, { "@ECHO OFF" })
      table.insert(commands, { '"' .. java_exec .. '"', "-jar", '"' .. java_formatter_jar .. '"', "%*" })
    end

    local java_formatter_exec_folder = path:new(vim.g.custom_formater_exec_folder)

    local script_lines = {}
    for _, line in ipairs(commands) do
      table.insert(script_lines, table.concat(line, " "))
    end

    local java_formatter_exec_path = java_formatter_exec_folder:joinpath(exec_file_name):absolute()
    coroutine.yield("Generating exec file " .. java_formatter_exec_path)
    if vim.fn.writefile(script_lines, java_formatter_exec_path) ~= 0 then
      coroutine.yield({ msg = "Failed to write exec file", level = vim.log.levels.ERROR })
      return false
    end

    if vim.fn.has("linux") == 1 then
      coroutine.yield("Altering file permissions")
      if vim.system({ "chmod", "+x", java_formatter_exec_path }):wait().code ~= 0 then
        coroutine.yield({ msg = "Failed to modify file permissions", level = vim.log.levels.ERROR })
        return false
      end
    end

    coroutine.yield("Exec generated succesfully")
    return true
  end,
  opts = function(_, opts)
    opts.formatters_by_ft.templ = { "templ" }

    local exec_file_name = "google-java-format"
    if vim.fn.has("win32") == 1 then
      exec_file_name = "google-java-format.cmd"
    end
    -- google java format
    local java_formatter_exec =
        require("plenary.path"):new(vim.g.custom_formater_exec_folder):joinpath(exec_file_name):absolute()
    if not vim.fn.filereadable(java_formatter_exec) then
      vim.notify("[Conform] Google java formatter not found!", vim.log.levels.WARN)
    else
      opts.formatters_by_ft.java = { "google-java-format" }
      opts.formatters["google-java-format"] = function(bufnr)
        local filePath = vim.uri_from_bufnr(bufnr)
        local prependArgs = {}
        local formatter_config = vim.fs.find(
          { ".google-java-format.json", "google-java-format.json" },
          { path = filePath, upward = true }
        )
        if not vim.tbl_isempty(formatter_config) then
          local ok, config = pcall(function()
            return vim.json.decode(table.concat(vim.fn.readfile(formatter_config[1]), ""))
          end)
          if ok then
            if config.format == "aosp" then
              table.insert(prependArgs, "-aosp")
            end
            if config["sort-imports"] == false then
              table.insert(prependArgs, "--skip-sorting-imports")
            end
            if config["remove-unused-imports"] == false then
              table.insert(prependArgs, "--skip-removing-unused-imports")
            end
            if config["format-javadoc"] == false then
              table.insert(prependArgs, "--skip-javadoc-formatting")
            end
          else
            vim.notify_once("[Conform] Invalid format for google-java-format config!", vim.log.levels.WARN)
          end
        end
        local appendArgs = { "-" }
        vim.list_extend(prependArgs, appendArgs)
        return {
          inherit = false,
          command = java_formatter_exec,
          stdin = true,
          args = prependArgs,
          range_args = function(self, ctx)
            local range_args = {
              "--lines",
              ctx.range.start[1] .. ":" .. ctx.range["end"][1],
            }
            vim.list_extend(range_args, prependArgs)
            if not vim.list_contains(range_args, "--skip-sorting-imports") then
              table.insert(range_args, 1, "--skip-sorting-imports")
            end
            if not vim.list_contains(range_args, "--skip-removing-unused-imports") then
              table.insert(range_args, 1, "--skip-removing-unused-imports")
            end
            return range_args
          end,
          condition = function(ctx)
            return vim.fs.find(
              { ".google-java-format.json", "google-java-format.json" },
              { path = ctx.filename, upward = true }
            )[1]
          end,
        }
      end
    end

    opts.formatters.injected.options.lang_to_formatters = {
      javascript = { "prettierd" },
    }

    if vim.fn.executable("tex-fmt") == 1 then
      opts.formatters.tex_fmt = {
        command = "tex-fmt",
        args = {"--stdin"},
        stdin = true,
      }

      opts.formatters_by_ft.tex = { "tex-fmt" }
    end
  end,
}
