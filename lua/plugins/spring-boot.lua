local cache_dir = vim.g.spring_cache_dir
return {
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
    local command = { "curl", "-L", "-o", tmp_file, download_link }
    vim.system(command, {
      stdout = on_output,
      stderr = on_output,
    }, on_exit)

    while not job_complete do
      vim.wait(10, function() end)
      if vim.tbl_isempty(output) then
        coroutine.yield()
      else
        coroutine.yield(table.concat(output, ""))
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
    opts.server = {
      root_dir = require("modules.java").javaRoot(vim.api.nvim_buf_get_name(0)),
      java_bin = require("modules.java").execAt(17),
      on_init = function(client)
        local rc = client.server_capabilities
        rc.inlayHintProvider = false
      end,
    }
    require("spring_boot").setup(opts)
  end,
}
