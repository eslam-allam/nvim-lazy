return {
  "linux-cultist/venv-selector.nvim",
  enabled = true,

  opts = function(_, opts)
    local conda_prefix = os.getenv("CONDA_PREFIX")
    local path_regex = '/envs/.*/bin/python$'
    if not conda_prefix then
      if vim.fn.has("windows") == 1 then
        conda_prefix = vim.fn.expand("~/AppData/Local/miniconda3")
        path_regex = 'envs//[^//]+//python.exe$'
      else
        error("conda_prefix not found")
      end
    end
    local function quote(str)
      return "'" .. str .. "'"
    end
    local cmd = { 'fd', quote(path_regex), quote(conda_prefix), '--full-path' }
    return vim.tbl_deep_extend("keep", {
      settings = {
        search = {
          miniconda = {
            command = table.concat(cmd, " "),
            type = "anaconda",
          },
        },
      },
    }, opts)
  end,
}
