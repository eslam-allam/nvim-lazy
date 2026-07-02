---@class secrets.secret : secrets.secret.cache
---@field generator string[]|fun():string

---@class secrets.opts
---@field secretsDir string
---@field secretsFileName string
---@field secrets table<string, secrets.secret>

---@class secrets.secret.cache
---@field value string

---@class secrets
---@field opts secrets.opts
---@field secrets table<string, secrets.secret>

---@class secrets
local M = {
  opts = {
    secretsDir = vim.fn.stdpath("data") .. "/secrets",
    secretsFileName = "secrets.json",
    secrets = {}
  },

  secrets = {},
}

---Notify with secrets prefix
---@param msg string
---@param lvl? vim.log.levels
local function notify(msg, lvl)
  if not lvl then
    lvl = vim.log.levels.INFO
  end
  vim.notify(msg, lvl, { title = "Secrets" })
end

local function getSecretsFilePath()
  return M.opts.secretsDir .. "/" .. M.opts.secretsFileName
end

local function refreshFromCache()
  local result = vim.fn.readfile(getSecretsFilePath())
  ---@type table<string, secrets.secret.cache>
  local cache = vim.json.decode(table.concat(result, "\n"))

  for name, _ in pairs(M.secrets) do
    local cached = cache[name]
    if cached ~= nil then
      M.secrets[name].value = cached.value
    end
  end
end

---@return boolean
local function writeCache()
  ---@type table<string, secrets.secret.cache>
  local cache = {}
  for name, secret in pairs(M.secrets) do
    cache[name] = { value = secret.value }
  end
  if vim.fn.writefile({vim.fn.json_encode(cache)}, getSecretsFilePath()) == -1 then
    notify("Failed to write secrets file...", vim.log.levels.ERROR)
    return false
  end
  return true
end

---@param opts secrets.opts
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts)
  if vim.fn.mkdir(M.opts.secretsDir, "p") == 0 then
    notify("Failed to create secrets directory. Please check permissions and try again.", vim.log.levels.ERROR)
    return
  end
  for name, secret in pairs(M.opts.secrets) do
    M.register(name, secret)
  end
  if vim.fn.filereadable(getSecretsFilePath()) == 0 then
    notify("Secrets file not found. Creating...", vim.log.levels.INFO)
    if not writeCache() then
      notify("Failed to create secrets file...", vim.log.levels.ERROR)
      return
    end
  else
    refreshFromCache()
  end
end

function M.has(name)
  return M.secrets[name] ~= nil
end

---@param name string
---@return string|nil
local function generateSecret(name)
  local secret = M.secrets[name]
  if secret.generator == nil then
    return nil
  end
  if type(secret.generator) == "function" then
    return secret.generator()
  end
  if not vim.islist(secret.generator) then
    notify("Secret generator for secret: " .. name .. " is not a list or function", vim.log.levels.WARN)
    return nil
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  local result = vim.system(secret.generator):wait()
  if result.code ~= 0 then
    notify(
      "Failed to generate secret: " .. name .. " : " .. result.stdout .. "\n" .. result.stderr,
      vim.log.levels.ERROR
    )
    return nil
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  local value = vim.trim(result.stdout == nil and "" or result.stdout)
  if vim.fn.empty(value) == 1 then
    notify("Generator returned empty result for secret: " .. name, vim.log.levels.WARN)
    return nil
  end
  return value
end

---@param name string Name of the secret to fetch
---@param refresh? boolean Refresh the secret using generator
---@return string|nil
function M.get(name, refresh)
  local secret = M.secrets[name]
  if secret == nil then
    notify("Attempted to grab secret that does not exist: " .. name, vim.log.levels.WARN)
    return nil
  end
  if refresh or secret.value == nil then
    local newValue = generateSecret(name)
    if newValue ~= nil then
      secret.value = newValue
      writeCache()
    end
  end
  return secret.value
end

---@param name string
---@param secret secrets.secret
function M.register(name, secret)
  if M.has(name) then
    notify("Attempt to register existing secret: " .. name, vim.log.levels.WARN)
    return
  end
  M.secrets[name] = secret
end

function M.get_bw_password(item_name)
    local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
    local dev_null = is_windows and "2>nul" or "2>/dev/null"

    local has_rbw = vim.fn.executable("rbw") == 1
    local has_bw = vim.fn.executable("bw") == 1

    if not has_rbw and not has_bw then
        vim.notify("Bitwarden Error: Neither 'rbw' nor 'bw' executables were found on your system PATH.", vim.log.levels.ERROR)
        return nil
    end

    -- 1. Try rbw first
    if has_rbw then
        local check_rbw = io.popen(string.format("rbw locked %s", dev_null))
        if check_rbw then
            local status = check_rbw:read("*a"):gsub("%s+", "")
            check_rbw:close()
            
            if status == "false" or status == "" then
                local rbw_cmd = string.format("rbw get \"%s\" %s", item_name, dev_null)
                local handle = io.popen(rbw_cmd)
                if handle then
                    local res = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
                    handle:close()
                    if res ~= "" then return res end
                end
            end
        end
    end

    -- 2. Fallback to official bw
    if has_bw then
        -- Step A: Handle Unlocking
        if not vim.g.bw_session or vim.g.bw_session == "" then
            local password = vim.fn.inputsecret("Enter Bitwarden Master Password: ")
            if password == "" then 
                vim.notify("Bitwarden: Unlock cancelled by user.", vim.log.levels.WARN)
                return nil 
            end

            local unlock_cmd = is_windows 
                and string.format("powershell -Command \"bw unlock --raw '%s'\"", password)
                or string.format("bw unlock --raw \"%s\" %s", password, dev_null)

            local handle = io.popen(unlock_cmd)
            if handle then
                local result = handle:read("*a"):gsub("%s+", "")
                handle:close()
                
                if result:match("^[A-Za-z0-9%+/=]+$") and #result > 20 then
                    vim.g.bw_session = result
                    vim.notify("Bitwarden vault unlocked successfully!", vim.log.levels.INFO)
                else
                    vim.notify("Bitwarden Error: Invalid master password or failed vault unlock.", vim.log.levels.ERROR)
                    return nil
                end
            else
                vim.notify("Bitwarden Error: Failed to execute the unlock command.", vim.log.levels.ERROR)
                return nil
            end
        end

        -- Step B: Handle Fetching (Attempt 1: Try password field)
        local fetch_pw_cmd = is_windows
            and string.format("powershell -Command \"$env:BW_SESSION='%s'; bw get password '%s'\"", vim.g.bw_session, item_name)
            or string.format("BW_SESSION=\"%s\" bw get password \"%s\" %s", vim.g.bw_session, item_name, dev_null)

        local fetch_handle = io.popen(fetch_pw_cmd)
        if fetch_handle then
            local password_value = fetch_handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
            fetch_handle:close()
            
            if password_value ~= "" and not password_value:match("[Ee]rror") then 
                return password_value 
            end
        end

        -- Step C: Fallback Fetching (Attempt 2: If password field was empty/error, try Notes)
        local fetch_notes_cmd = is_windows
            and string.format("powershell -Command \"$env:BW_SESSION='%s'; bw get notes '%s'\"", vim.g.bw_session, item_name)
            or string.format("BW_SESSION=\"%s\" bw get notes \"%s\" %s", vim.g.bw_session, item_name, dev_null)

        local notes_handle = io.popen(fetch_notes_cmd)
        if notes_handle then
            local notes_value = notes_handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
            notes_handle:close()
            
            if notes_value ~= "" and not notes_value:match("[Ee]rror") then 
                return notes_value 
            end
        end

        -- If both password and notes failed
        vim.notify(string.format("Bitwarden Error: Could not find data or notes for item '%s'.", item_name), vim.log.levels.ERROR)
    end

    return nil
end

return M
