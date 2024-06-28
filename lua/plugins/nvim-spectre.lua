return {
  "nvim-pack/nvim-spectre",
  keys = function()
    return {
      {
        "<leader>sF",
        function()
          require("spectre").open_file_search()
        end,
        desc = "Spectre File (Selected)",
        mode = { "n", "x" },
      },
    }
  end,
}
