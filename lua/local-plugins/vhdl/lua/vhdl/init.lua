local M = {}
local path = require("plenary.path")
local pathEnvSeparator = vim.fn.has("win32") == 1 and ";" or ":"
local formatterFileName = vim.fn.has("win32") == 1 and "vhdlfmt.exe" or "vhdlfmt"

---@class setup.opts.silicon
---@field userCommand string
---@field syntaxFileUrl string
---@field batConfigDir string?

---@class setup.opts.fmt.binUrl
---@field linux string
---@field windows string

---@class setup.opts.fmt
---@field userCommand string
---@field binUrl setup.opts.fmt.binUrl

---@class setup.opts
---@field fmtDir string
---@field silicon setup.opts.silicon
---@field fmt setup.opts.fmt

---@type setup.opts
M.opts = {
  fmtDir = path:new(vim.fn.stdpath("data")):joinpath("vhdl", "bin"):absolute(),
  silicon = {
    userCommand = "VHDLSiliconSyntaxDownload",
    syntaxFileUrl = "https://raw.githubusercontent.com/TheClams/SmartVHDL/refs/heads/master/VHDL.sublime-syntax",
    batConfigDir = nil,
  },
  fmt = {
    userCommand = "VHDLFormatDownload",
    binUrl = {
      linux = "https://releases.vhdlfmt.com/0.0.0-SNAPSHOT-7403572/vhdlfmt_0.0.0-SNAPSHOT-7403572_linux_amd64.zip",
      windows = "https://releases.vhdlfmt.com/0.0.0-SNAPSHOT-7403572/vhdlfmt_0.0.0-SNAPSHOT-7403572_windows_amd64.zip",
    },
  },
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  if vim.fn.executable("vhdlfmt") == 0 then
    if path:new(M.opts.fmtDir):joinpath(formatterFileName):exists() then
      vim.env.PATH = vim.env.PATH .. pathEnvSeparator .. M.opts.fmtDir
    else
      vim.notify(
        "[VHDL] vhdlfmt not available. Please run '" .. M.opts.fmt.userCommand .. "' to download it",
        vim.log.levels.WARN
      )
    end
  end

  vim.api.nvim_create_user_command(M.opts.silicon.userCommand, function()
    if vim.fn.executable("silicon") == 0 then
      vim.notify("[VHDL] silicon not available. Please install and try again.", vim.log.levels.ERROR)
      return
    end

    if vim.fn.executable("curl") == 0 then
      vim.notify("[VHDL] curl not available. Please install and try again.", vim.log.levels.ERROR)
      return
    end

    local batCommand = vim.fn.executable("bat") == 1 and "bat" or vim.fn.executable("batcat") == 1 and "batcat" or nil

    if batCommand ~= nil and M.opts.silicon.batConfigDir == nil then
      local result = vim.system({ batCommand, "--config-dir" }, { text = true }):wait()
      if result.code ~= 0 then
        vim.notify("[VHDL] Failed to get bat config dir", vim.log.levels.ERROR)
        return
      end
      M.opts.silicon.batConfigDir = result.stdout:gsub("\n", "")
    end

    if M.opts.silicon.batConfigDir == nil then
      vim.notify("[VHDL] bat config dir not available. Please set it manually.", vim.log.levels.ERROR)
      return
    end
    local batConfigDir = path:new(M.opts.silicon.batConfigDir)

    vim.notify("[VHDL] Creating necessary directories...", vim.log.levels.INFO)
    local syntaxDir = batConfigDir:joinpath("syntaxes")
    if not syntaxDir:exists() and not syntaxDir:mkdir({ parents = true }) then
      vim.notify("[VHDL] Failed to create syntax dir", vim.log.levels.ERROR)
      return
    end

    local themesDir = batConfigDir:joinpath("themes")

    if not themesDir:exists() and not themesDir:mkdir({ parents = true }) then
      vim.notify("[VHDL] Failed to create themes dir", vim.log.levels.ERROR)
      return
    end

    local syntaxFilePath = syntaxDir:joinpath("VHDL.sublime-syntax")

    vim.notify("[VHDL] Downloading VHDL syntax file...", vim.log.levels.INFO)
    require("plenary.job")
      ---@diagnostic disable-next-line: missing-fields
      :new({
        command = "curl",
        args = { "-L", "-o", syntaxFilePath:absolute(), M.opts.silicon.syntaxFileUrl },
        on_exit = function(_, downloadCode)
          if downloadCode ~= 0 then
            vim.notify("[VHDL] Failed to download VHDL syntax file", vim.log.levels.ERROR)
            return
          end
          vim.notify("[VHDL] VHDL syntax file downloaded successfully.", vim.log.levels.INFO)
          vim.notify("[VHDL] Rebuilding Silicon cache...", vim.log.levels.INFO)
          require("plenary.job")
            ---@diagnostic disable-next-line: missing-fields
            :new({
              command = "silicon",
              args = { "--build-cache" },
              cwd = batConfigDir:absolute(),
              on_exit = function(_, buildCode)
                if buildCode ~= 0 then
                  vim.notify("[VHDL] Failed to build silicon cache", vim.log.levels.ERROR)
                  return
                end

                vim.notify("[VHDL] Silicon cache built successfully.", vim.log.levels.INFO)
              end,
            })
            :start()
        end,
      })
      :start()
  end, {})

  vim.api.nvim_create_user_command(M.opts.fmt.userCommand, function()
    if vim.fn.executable("vhdlfmt") == 1 then
      vim.notify("[VHDL] vhdlfmt already available. Skipping download.", vim.log.levels.WARN)
      return
    end

    if vim.fn.executable("curl") == 0 then
      vim.notify("[VHDL] curl not available. Please install and try again.", vim.log.levels.ERROR)
      return
    end

    if vim.fn.has("linux") == 1 and vim.fn.executable("unzip") == 0 then
      vim.notify("[VHDL] unzip not available. Please install and try again.", vim.log.levels.ERROR)
      return
    end

    local fmtDir = path:new(M.opts.fmtDir)

    if not fmtDir:exists() then
      vim.notify("[VHDL] bin directory does not exist. Creating...", vim.log.levels.INFO)
      local ok, res = pcall(function()
        return fmtDir:mkdir({ parents = true })
      end)
      if not ok then
        vim.notify(
          "[VHDL] failed to create bin directory. Please check permissions and try again: " .. res,
          vim.log.levels.ERROR
        )
        return
      end
    end

    local vhdlfmtUrl = vim.fn.has("win32") == 1 and M.opts.fmt.binUrl.windows or M.opts.fmt.binUrl.linux

    vim.notify("[VHDL] Downloading VHDLfmt...", vim.log.levels.INFO)

    local tempLocation = vim.fn.tempname() .. ".zip"

    local function tempLocationDel()
      vim.schedule(function()
        if vim.fn.delete(tempLocation) == -1 then
          vim.notify("[VHDL] failed to delete temporary file at: '." .. tempLocation .. "'", vim.log.levels.WARN)
        else
          vim.notify("[VHDL] Cleanup succesfull", vim.log.levels.INFO)
        end
      end)
    end

    require("plenary.job")
      ---@diagnostic disable-next-line: missing-fields
      :new({
        command = "curl",
        args = { "-L", "-o", tempLocation, vhdlfmtUrl },
        on_exit = function(_, downloadCode)
          local succ = downloadCode == 0
          if not succ then
            vim.notify(
              "[VHDL] failed to download VHDLfmt. Please check your internet connection and try again.",
              vim.log.levels.ERROR
            )
            return
          end

          vim.notify("[VHDL] Extracting VHDLfmt...", vim.log.levels.INFO)
          local extractCmd = { "unzip", tempLocation, "-d", fmtDir:absolute() }
          if vim.fn.has("win32") == 1 then
            extractCmd =
              { "powershell.exe", "Expand-Archive", "-Path", tempLocation, "-DestinationPath", fmtDir:absolute() }
          end

          require("plenary.job")
            ---@diagnostic disable-next-line: missing-fields
            :new({
              command = extractCmd[1],
              args = { unpack(extractCmd, 2) },
              on_exit = function(_, extractCode)
                succ = extractCode == 0
                if not succ then
                  vim.notify("[VHDL] failed to extract VHDLfmt.", vim.log.levels.ERROR)
                  vim.notify("[VHDL] Cleaning up...", vim.log.levels.INFO)
                  tempLocationDel()
                  return
                end

                vim.notify("[VHDL] VHDLfmt downloaded and extracted successfully.", vim.log.levels.INFO)

                vim.notify("[VHDL] Cleaning up...", vim.log.levels.INFO)
                tempLocationDel()

                if vim.fn.executable("vhdlfmt") == 0 then
                  vim.schedule(function()
                    vim.env.PATH = vim.env.PATH .. pathEnvSeparator .. M.opts.fmtDir
                  end)
                end
              end,
            })
            :start()
        end,
      })
      :start()
  end, {})
end

return M
