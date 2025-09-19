-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.filetype.add({
  pattern = {
    [".*%.env.*"] = "sh",
  },
})

-- LSP Options
vim.lsp.enable("postgres_lsp")

-- Silence splitjoin
vim.g.splitjoin_quiet = 1
