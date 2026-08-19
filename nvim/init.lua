vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
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
    },
    {
      "preservim/tagbar",
      cmd = "TagbarToggle",
      keys = {
        { "<leader>t", "<cmd>TagbarToggle<CR>", desc = "Toggle Tagbar" },
      },
      init = function() 
        vim.g.tagbar_width = 40
        vim.g.tagbar_autofocus = 1
        vim.g.tagbar_map_showproto = "\\" -- \ to see the tag prototype
      end
    },
  },
  checker = { enabled = true },
})

vim.keymap.set("n", "<leader>o", function()
  local oil = require("oil")
  if vim.bo.filetype == "oil" then
    vim.cmd("bd")
  else
    oil.open()
  end
end)

local function toggle_tagbar()
  if vim.bo.filetype == "tagbar" then
    vim.cmd("TagbarClose")
  else
    vim.cmd("TagbarToggle")
  end
end

vim.keymap.set("n", "<leader>t", toggle_tagbar, { desc = "Toggle Tagbar", silent = true })


-- Mark add
vim.api.nvim_create_user_command("Ma", function()
  if vim.b.marked then
    return
  end
  local max_mark = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].marked then
      max_mark = math.max(max_mark, vim.b[bufnr].mark_number or 0)
    end
  end
  vim.b.marked = true
  vim.b.mark_number = max_mark + 1
  vim.api.nvim_echo({}, false, {})
end, {})

-- Mark delete
vim.api.nvim_create_user_command("Md", function()
  vim.b.marked = false
  vim.b.mark_number = nil
  vim.api.nvim_echo({}, false, {})
end, {})

-- Jump to marked buffer
vim.api.nvim_create_user_command("M", function(opts)
  local mark_number = tonumber(opts.args)
  if not mark_number then
    vim.notify("Usage: :M <number>", vim.log.levels.ERROR)
    return
  end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr)
        and vim.b[bufnr].marked
        and vim.b[bufnr].mark_number == mark_number then
      vim.api.nvim_set_current_buf(bufnr)
      return
    end
  end
  vim.notify("No marked buffer " .. mark_number, vim.log.levels.WARN)
end, {
  nargs = 1,
})

-- List marked buffers
vim.api.nvim_create_user_command("Ms", function()
  local marked = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].marked then
      table.insert(marked, bufnr)
    end
  end
    if #marked == 0 then
      vim.notify("No marked buffers", vim.log.levels.INFO)
      return
    end
  table.sort(marked, function(a, b)
    return vim.b[a].mark_number < vim.b[b].mark_number
  end)
  for _, bufnr in ipairs(marked) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    local relative_name = vim.fn.fnamemodify(name, ":.")
    print(vim.b[bufnr].mark_number .. " " .. relative_name)
  end
end, {})

