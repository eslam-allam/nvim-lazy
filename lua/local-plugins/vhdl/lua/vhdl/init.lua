local M = {}
local path = require("plenary.path")
local pathEnvSeparator = vim.fn.has("win32") == 1 and ";" or ":"
local formatterFileName = vim.fn.has("win32") == 1 and "vhdlfmt.exe" or "vhdlfmt"

M.opts = {
  fmtDir = path:new(vim.fn.stdpath("data")):joinpath("vhdl", "bin"):absolute(),
}

local downloadCmd = "VhdlFmtDownload"

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  if vim.fn.executable("vhdlfmt") == 0 then
    if path:new(M.opts.fmtDir):joinpath(formatterFileName):exists() then
      vim.env.PATH = vim.env.PATH .. pathEnvSeparator .. M.opts.fmtDir
    else
      vim.notify("[VHDL] vhdlfmt not available. Please run '" .. downloadCmd .. "' to download it", vim.log.levels.WARN)
    end
  end

  vim.api.nvim_create_user_command(downloadCmd, function()
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

    local vhdlfmtUrl =
      "https://releases.vhdlfmt.com/0.0.0-SNAPSHOT-7403572/vhdlfmt_0.0.0-SNAPSHOT-7403572_linux_amd64.zip"

    if vim.fn.has("win32") == 1 then
      vhdlfmtUrl =
        "https://releases.vhdlfmt.com/0.0.0-SNAPSHOT-7403572/vhdlfmt_0.0.0-SNAPSHOT-7403572_windows_amd64.zip"
    end

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
