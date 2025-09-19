-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local default_group = vim.api.nvim_create_augroup("custom_autocommands", { clear = true })

-- Toggle relative line numbers based on mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = default_group,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = default_group,
  callback = function()
    vim.opt.relativenumber = true
  end,
})

-- Focus "${cwd}/" buffer (e.g. "nvim/") after a session restore
vim.api.nvim_create_autocmd("User", {
  group = default_group,
  pattern = "PersistenceLoadPost",
  callback = function()
    local target = vim.fn.getcwd()
    local current_win = vim.api.nvim_get_current_win()

    vim.schedule(function()
      local target_buf = nil
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
          if vim.api.nvim_buf_get_name(buf) == target then
            target_buf = buf
            break
          end
        end
      end

      if not target_buf then
        return
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == target_buf then
          vim.api.nvim_set_current_win(win)
          return
        end
      end

      vim.api.nvim_set_current_buf(target_buf)

      vim.schedule(function()
        vim.api.nvim_set_current_win(current_win)
      end)
    end)
  end,
})
