-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.harpoon")
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})
require("dapui").setup()

-- default theme
vim.cmd("colorscheme catppuccin-mocha")
