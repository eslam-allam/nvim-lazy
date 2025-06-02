return {
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
