vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- set space as a leader key
vim.g.mapleader = " "


-- Toggle Quickfix List
vim.keymap.set('n', '<leader>q', function()
  local qf_open = false
  -- Loop through all windows and check if any has quickfix open
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      qf_open = true
      break
    end
  end
  if qf_open then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
    vim.cmd('resize 30')
  end
end, { noremap = true, silent = true })


-- Option + jk to navigatie in Quickfix List
vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>')
vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>')


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "catppuccin/nvim", 
      name = "catppuccin", 
      priority = 1000,
      config = function () 
        vim.opt.termguicolors = true
        vim.opt.background = "dark"
        vim.cmd("colorscheme catppuccin")
      end
    },
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
         winopts = {
          height = 0.95,
          width = 0.8,
          preview = {
            layout = "horizontal",
            horizontal = "down",
            win_height = 0.3,
          },
        },
        files = {
          prompt = "Files> ",
          multiprocess = true,
          git_icons = true,
        },
        grep = {
          prompt = "Grep> ",
          rg_opts = "--hidden -g '!.git/' --column --line-number --no-heading --color=always",
          multiprocess = true,
          preview = "bat --style=numbers --color=always --line-range=:300 {}",
        },
      },
      config = function(_, opts)
        local fzf = require("fzf-lua")
        fzf.setup(opts)
        vim.keymap.set("n", "<leader>f", fzf.files, { desc = "FZF find files" })
        vim.keymap.set("n", "<leader>g", fzf.live_grep, { desc = "FZF live grep" })
        vim.keymap.set("n", "<leader>h", fzf.history, { desc = "FZF search history" })
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      opts = {
        ensure_installed = { 'c', 'cpp', 'python' },
        highlight = { enable = true },
        indent = { enable = true },
      },
    },
    {
      'stevearc/oil.nvim',
      opts = {},
      dependencies = { "nvim-tree/nvim-web-devicons" },
      lazy = false,
    }
  },
  checker = { enabled = true },
})


vim.keymap.set("n", "<leader>o", function()
  local oil = require("oil")
  if vim.bo.filetype == "oil" then
    vim.cmd("bd")
  else
    oil.open_float()
  end
end)
