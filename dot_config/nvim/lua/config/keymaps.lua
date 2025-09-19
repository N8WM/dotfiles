-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Delete default window resizing keymaps
vim.keymap.del("n", "<C-Up>")
vim.keymap.del("n", "<C-Down>")
vim.keymap.del("n", "<C-Left>")
vim.keymap.del("n", "<C-Right>")

-- Resize window using <alt> arrow keys
vim.keymap.set("n", "<C-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height", silent = true })
vim.keymap.set("n", "<C-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height", silent = true })
vim.keymap.set("n", "<C-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width", silent = true })
vim.keymap.set("n", "<C-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width", silent = true })

-- Copy all
vim.keymap.set("n", "<C-S-C>", 'gg0vG$"+y', { desc = "Copy buffer", silent = true })
vim.keymap.set("i", "<C-S-C>", '<esc>gg0vG$"+y', { desc = "Copy buffer", silent = true })
vim.keymap.set("v", "<C-S-C>", '"+y', { desc = "Copy selection", silent = true })
