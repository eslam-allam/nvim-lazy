return {
  "linux-cultist/venv-selector.nvim",
  lazy = false,
  enabled = true,
  branch = "main",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    settings = {
      search = {
        miniconda_arch = {
          command = "fd 'bin/python$' /opt/miniconda3/envs --no-ignore-vcs --full-path --color never",
          type = "anaconda",
        },
        mamba = {
          command = "fd 'bin/python$' ~/.local/share/mamba/envs --no-ignore-vcs --full-path --color never",
          type = "anaconda",
        },
      },
    },
  },
}
