return {
  {
    "benlubas/molten-nvim",
    cond = vim.fn.has("win32") == 0,
    ft = "quarto",
    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        optional = true,
        ft = { "quarto" },
        opts = {
          filetypes = { "quarto" },
        }
      },
      {
        "3rd/image.nvim",
        dependencies = {
          "vhyrro/luarocks.nvim",
          priority = 1001,
          opts = {
            rocks = { "magick" },
          },
        },
        opts = {
          backend = "kitty",
          integrations = {
            markdown = {
              enabled = true,
              clear_in_insert_mode = false,
              download_remote_images = true,
              filetypes = { "quarto" }
            },
          },
          max_width = 500,
          max_height = 500,
          max_height_window_percentage = math.huge,
          max_width_window_percentage = math.huge,
          window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
          window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "noice", "" },
          tmux_show_only_in_active_window = true,
        },
      },
      {
        "GCBallesteros/jupytext.nvim",
        lazy = false,
        opts = {
          style = "quarto",
          output_extension = "qmd",
          force_ft = "quarto",
        }
      },
      {
        "quarto-dev/quarto-nvim",
        ft = { "quarto" },
        dependencies = {
          "jmbuhr/otter.nvim",
          "nvim-treesitter/nvim-treesitter",
        },
        config = function(_, opts)
          require("quarto").setup(opts)
          local runner = require("quarto.runner")
          require("which-key").add({
            "<localleader>r",
            group = "Quarto",
            { "<localleader>rc", runner.run_cell,  desc = "Run Cell" },
            { "<localleader>ra", runner.run_above, desc = "Run Cell and Above" },
            { "<localleader>rA", runner.run_all,   desc = "Run All Cell" },
            { "<localleader>rl", runner.run_line,  desc = "Run Line" },
            { "<localleader>rc", runner.run_cell,  desc = "Run Cell" },
            { "<localleader>rc", runner.run_cell,  desc = "Run Cell" },
          }, {})
        end,
        opts = {
          lspFeatures = {
            -- NOTE: put whatever languages you want here:
            languages = { "python" },
            chunks = "all",
            diagnostics = {
              enabled = true,
              triggers = { "BufWritePost" },
            },
            completion = {
              enabled = true,
            },
          },
          keymap = {
            -- NOTE: setup your own keymaps:
            hover = "H",
            definition = "gd",
            rename = "<leader>rn",
            references = "gr",
            format = "<leader>gf",
          },
          codeRunner = {
            enabled = true,
            default_method = "molten",
          },
        }
      },
      {
        "chrisgrieser/nvim-various-textobjs",
        event = "UIEnter",
        opts = { keymaps = { useDefaults = false } },
      },
    },
    build = ":UpdateRemotePlugins",
    config = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_init_behavior = "init"
      vim.g.molten_enter_output_behavior = "open_and_enter"
      vim.g.molten_auto_image_popup = false
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_crop_border = false
      vim.g.molten_output_virt_lines = true
      vim.g.molten_output_win_max_height = 50
      vim.g.molten_output_win_style = "minimal"
      vim.g.molten_output_win_hide_on_leave = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_max_lines = 10000
      vim.g.molten_cover_empty_lines = false
      vim.g.molten_copy_output = true
      vim.g.molten_output_show_exec_time = false
    end,
  },
}
