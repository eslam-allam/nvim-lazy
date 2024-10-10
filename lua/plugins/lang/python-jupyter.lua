return {
  {
    "benlubas/molten-nvim",
    dependencies = {
      {
        "chrisgrieser/nvim-various-textobjs",
        event = "UIEnter",
        opts = { useDefaultKeymaps = false },
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
            },
          },
          max_width = 500,
          max_height = 500,
          max_height_window_percentage = math.huge,
          max_width_window_percentage = math.huge,
          window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
          window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "noice", "" },
        },
      },
      {
        "AckslD/nvim-FeMaco.lua",
        config = true,
        init = function()
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function(event)
              vim.keymap.set("n", "<C-CR>", function() require('femaco.edit').edit_code_block() end, { buffer = event.buf, desc = "Edit Code Block" })
            end
          })
        end,
        opts = {
          prepare_buffer = function(opts)
              local buf = vim.api.nvim_create_buf(false, false)
              vim.keymap.set({"n", "i"}, "<C-s>", "<cmd>close<CR>", { buffer = buf, desc = "Close" })
              return vim.api.nvim_open_win(buf, true, opts)
            end,
        }
      },
    },
    build = ":UpdateRemotePlugins",
    init = function()
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
    keys = {
      {
        "<S-Enter>",
        function()
          require("various-textobjs").mdFencedCodeBlock("inner")
          vim.cmd("MoltenEvaluateOperator")
        end,
        desc = "Molten Eval Block",
        mode = "n",
        ft = { "markdown" },
      },
      {
        "<S-Enter>",
        function()
          vim.cmd("stopinsert")
          require("various-textobjs").mdFencedCodeBlock("inner")
          vim.cmd("MoltenEvaluateOperator")
        end,
        desc = "Molten Eval Block",
        mode = "i",
        ft = { "markdown" },
      },
    },
  },
}
