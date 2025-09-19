return {
  "folke/persistence.nvim",
  opts = {
    options = vim.opt.sessionoptions:get(),
    pre_save = function()
      -- Close Snacks picker before saving
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match("/$") and vim.bo[buf].buftype == "" then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end,
  },
}
