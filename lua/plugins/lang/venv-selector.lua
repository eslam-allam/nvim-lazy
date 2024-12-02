return {
  "linux-cultist/venv-selector.nvim",

  opts = function(_, opts)
    local conda_prefix = os.getenv("CONDA_PREFIX")
    if not conda_prefix then
      if vim.fn.has("windows") == 1 then
        conda_prefix = vim.fn.expandcmd("~/AppData/Local/miniconda3")
      else
        error("conda_prefix not found")
      end
    end
    return vim.tbl_deep_extend("keep", {
      settings = {
        search = {
          miniconda = {
            command = "fd '/envs/.*/bin/python$' " .. conda_prefix .. " --full-path",
            type = "anaconda",
          },
        },
      },
    }, opts)
  end,
}
