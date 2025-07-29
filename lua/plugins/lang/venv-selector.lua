return {
  "linux-cultist/venv-selector.nvim",
  lazy = false,
  enabled = true,
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
      },
    },
  },
}
