return {
  "stevearc/conform.nvim",
  build = function()
    if vim.fn.isdirectory(vim.g.custom_formater_exec_folder) == 0 then
      coroutine.yield("Creating custom formatter exec folder")
      if vim.fn.mkdir(vim.g.custom_formater_exec_folder, "p") == 0 then
        coroutine.yield({ msg = "Failed to create custom formatter exec folder", level = vim.log.levels.ERROR })
        return false
      end
    end

    coroutine.yield("Finding google-java-format installation")
    local java_formatter_jar_dir = require("mason-registry").get_package("google-java-format"):get_install_path()
    local java_formatter_jar = vim.fn.glob(java_formatter_jar_dir .. "/google-java-format-*.jar")
    if java_formatter_jar == "" then
      coroutine.yield({ msg = "Google java formatter not found!", level = vim.log.levels.WARN })
      return false
    end

    local java_exec = require("modules.java").execAtleast(11)
    local command = { "exec", java_exec, "-jar", '"' .. java_formatter_jar .. '"', '"$@"' }

    local java_formatter_exec_path = vim.g.custom_formater_exec_folder .. "/google-java-format"
    coroutine.yield("Generating exec file " .. java_formatter_exec_path)
    if vim.fn.writefile({ "#!/usr/bin/env bash", "", table.concat(command, " ") }, java_formatter_exec_path) ~= 0 then
      coroutine.yield({ msg = "Failed to write exec file", level = vim.log.levels.ERROR })
      return false
    end

    coroutine.yield("Altering file permissions")
    if vim.system({ "chmod", "+x", java_formatter_exec_path }):wait().code ~= 0 then
      coroutine.yield({ msg = "Failed to modify file permissions", level = vim.log.levels.ERROR })
      return false
    end

    coroutine.yield("Exec generated succesfully")
    return true
  end,
  opts = function(_, opts)
    opts.formatters_by_ft.templ = { "templ", "injected" }

    -- google java format
    local java_formatter_exec = vim.g.custom_formater_exec_folder .. "/google-java-format"
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
  end,
}
