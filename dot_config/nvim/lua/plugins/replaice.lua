return {
  "N8WM/replaice.nvim",
  config = function()
    require("replaice").setup({
      provider = "ollama",
      model = "gemma4:31b-cloud",
      keymap = "<c-r>",
      refine = {
        enabled = true,
        max_tries = 3,
      },
    })
  end,
}
