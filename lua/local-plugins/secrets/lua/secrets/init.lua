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

return M
