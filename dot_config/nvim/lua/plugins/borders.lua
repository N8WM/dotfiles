return {
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true, -- adds a border to LSP docs Noice shows
      },
      lsp = {
        hover = { opts = { border = "rounded" } },
        signature = { opts = { border = "rounded" } },
      },
    },
  },
  {
    "blink.cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.menu = vim.tbl_deep_extend("force", opts.completion.menu or {}, {
        border = "rounded",
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
      })
      opts.completion.documentation = vim.tbl_deep_extend("force", opts.completion.documentation or {}, {
        window = {
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
        },
        auto_show = true,
      })
    end,
  },
  {
    "mason.nvim",
    opts = { ui = { border = "rounded" } },
  },
  -- See lua/config/lazy for lazy ui border rounded
}
