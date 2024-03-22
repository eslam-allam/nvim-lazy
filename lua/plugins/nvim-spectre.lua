return {
  "nvim-pack/nvim-spectre",
  keys = {
    {"<leader>sf", function() require("spectre").open_file_search({select_word=true}) end, desc="Spectre File (Current Word)", mode={"n"}},
    {"<leader>sF", function() require("spectre").open_file_search() end, desc="Spectre File (Selected)", mode={"n", "x"}},
  }
}
