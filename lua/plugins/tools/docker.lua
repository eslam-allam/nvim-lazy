return {
  {
    "crnvl96/lazydocker.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    cmd = "LazyDocker",
    init = function()
      require("which-key").add({
        {
          "<leader>kd",
          "<cmd>LazyDocker<CR>",
          desc = "Open Lazy Docker",
          mode = { "n" },
          icon = { cat = "filetype", name = "DockerFile" },
        },
      }, {})
    end,
    config = function()
      require("lazydocker").setup()
    end,
  },
  {
    "ramilito/kubectl.nvim",
    lazy = true,
    init = function()
      require("which-key").add({
        "<leader>k",
        desc = "Kubernetes",
        icon = { icon = "󱃾", color = "blue" },
        -- stylua: ignore
        { "<leader>kk", function () require("kubectl").open() end, desc = "Open Kubectl", mode = { "n" } },
      }, {})
    end,
    config = true,
  },
}
