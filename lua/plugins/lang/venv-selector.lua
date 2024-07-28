return {
  "linux-cultist/venv-selector.nvim",
  opts = {
    settings = {
      search = {
        miniconda = {
          command = "fd '/envs/.*/bin/python$' " .. os.getenv("CONDA_PREFIX") .. " --full-path",
          type = "anaconda"
        }
      }
    }
  },
}
