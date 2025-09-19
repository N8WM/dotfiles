return {
  {
    "tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.Normal = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }

        hl.TabLine = { bg = "NONE" }
        hl.TabLineFill = { bg = "NONE" }

        hl.BufferLineFill = { bg = "NONE" }
        hl.BufferLineBackground = { bg = "NONE" }
        hl.BufferLineBufferVisible = { bg = "NONE" }
        hl.BufferLineBufferSelected = { bg = "NONE" }
        hl.BufferLineSeparator = { fg = c.border, bg = "NONE" }
        hl.BufferLineSeparatorVisible = { fg = c.border, bg = "NONE" }
        hl.BufferLineSeparatorSelected = { fg = c.border, bg = "NONE" }
        hl.BufferLineOffsetSeparator = { fg = c.border, bg = "NONE" }
        hl.WinSeparator = { fg = c.border, bg = "NONE" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-moon",
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.separator_style = { "", "" }
      opts.options.show_close_icon = false
      opts.options.show_buffer_close_icons = false
      opts.options.offsets = opts.options.offsets or {}

      local have_snacks = false
      for _, off in ipairs(opts.options.offsets) do
        if off.filetype == "snacks_layout_box" then
          off.separator = true
          have_snacks = true
        end
      end
      if not have_snacks then
        table.insert(opts.options.offsets, { filetype = "snacks_layout_box", separator = true })
      end

      return opts
    end,
  },
}
