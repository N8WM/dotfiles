return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      eslint = {
        settings = {
          rulesCustomizations = {
            {
              rule = "*",
              severity = "off",
            },
          },
        },
      },
    },
  },
}
