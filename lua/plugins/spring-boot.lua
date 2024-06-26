local cache_dir = vim.g.spring_cache_dir
return {
  "eslam-allam/spring-boot.nvim",
  ft = "java",
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

    coroutine.yield("finding target asset...")
    local download_link = nil
    for _, asset in ipairs(response_table.assets) do
      if asset.browser_download_url then
        if type(asset.browser_download_url) == "string" and asset.browser_download_url:sub(-4) == "vsix" then
          download_link = asset.browser_download_url
          break
        end
      end
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
    local job_code = 0
    local function on_exit(result)
      vim.schedule(function()
        job_complete = true
        job_code = result.code
      end)
    end
    local command = { "wget", "--output-document", tmp_file, download_link }
    vim.system(command, {
      stdout = on_output,
      stderr = on_output,
    }, on_exit)

    while not job_complete do
      vim.wait(10, function() end)
      if vim.tbl_isempty(output) then
        coroutine.yield()
      else
        coroutine.yield(table.concat(output, "\n"))
        output = {}
      end
    end

    if job_code ~= 0 then
      error("failed to download asset", vim.log.levels.ERROR)
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

    local out = vim.fn.system(table.concat({ "mv", cache_dir .. "/extension/*", cache_dir }, " "))
    coroutine.yield(out)

    coroutine.yield("deleting extension folder")
    if vim.fn.delete(cache_dir .. "/extension", "d") ~= 0 then
      error("failed to delete extension folder", vim.log.levels.ERROR)
    end
    vim.notify("Succesfully built Spring-ls")
  end,
  config = function(_, opts)
    opts.ls_path = cache_dir .. "/language-server"
    opts.server = {
      root_dir = require("modules.java").javaRoot(vim.api.nvim_buf_get_name(0)),
      java_bin = require("modules.java").execAt(17),
    }
    require("spring_boot").setup(opts)
  end,
}
