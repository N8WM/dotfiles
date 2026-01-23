return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    local new_opts = {
      dashboard = {
        preset = {
          header = [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
      },
      picker = {
        hidden = true,
        ignored = true,
        sources = {
          files = {
            hidden = true,
            ignored = true,
          },
          explorer = {
            layout = {
              auto_hide = { "input" },
            },
          },
        },
      },
      styles = {
        terminal = {
          wo = {
            -- disable term title
            winbar = "",
          },
        },
      },
    }

    vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "SnacksPickerPath" })
    pcall(vim.api.nvim_set_hl, 0, "SnacksExplorerPathHidden", { link = "SnacksExplorerPath" })

    opts = opts or {}
    opts = vim.tbl_deep_extend("force", opts, new_opts)

    return opts
  end,
}
