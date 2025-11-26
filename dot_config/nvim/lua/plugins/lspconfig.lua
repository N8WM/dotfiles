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
      },
    },
  },
  {
    "mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "arduino-language-server",
        "bash-language-server",
        "beautysh",
        "black",
        "css-lsp",
        "docker-compose-language-service",
        "docker-language-server",
        "dockerfile-language-server",
        "eslint-lsp",
        "eslint_d",
        "hadolint",
        "json-lsp",
        "lua-language-server",
        "markdown-toc",
        "markdownlint-cli2",
        "marksman",
        "postgres-language-server",
        "prettierd",
        "prisma-language-server",
        "shfmt",
        "stylua",
        "tree-sitter-cli",
        "typescript-language-server",
        "vtsls",
      },
    },
  },
}
