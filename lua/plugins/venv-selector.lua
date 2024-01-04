return {
  "linux-cultist/venv-selector.nvim",
  opts = {
    anaconda_envs_path = os.getenv("CONDA_PREFIX") .. "/envs",
  },
}
