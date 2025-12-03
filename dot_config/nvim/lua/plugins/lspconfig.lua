return {
  {
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
        zls = {
          settings = {
            zls = {
              enable_build_on_save = true,
              build_on_save_args = { "check", "-fincremental", "--watch" },
            },
          },
        },
      },
    },
  },
  {
    "mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "arduino_language_server",
        "bashls",
        "cssls",
        "docker_compose_language_service",
        "docker_language_server",
        "dockerls",
        "eslint",
        "jsonls",
        "lua_ls",
        "marksman",
        "postgres_lsp",
        "prismals",
        "stylua",
        "ts_ls",
        "vtsls",
      },
    },
  },
}
