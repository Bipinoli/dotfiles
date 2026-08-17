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


-- Custom command to pin the current buffer 
vim.api.nvim_create_user_command("Pn", function()
  if vim.b.pinned then
    return
  end
  local max_pin = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].pinned then
      max_pin = math.max(max_pin, vim.b[bufnr].pin_number or 0)
    end
  end
  vim.b.pinned = true
  vim.b.pin_number = max_pin + 1
  vim.api.nvim_echo({}, false, {})
end, {})

-- Custom command to unpin the current buffer 
vim.api.nvim_create_user_command("Unpn", function()
  vim.b.pinned = false
  vim.b.pin_number = nil
  vim.api.nvim_echo({}, false, {})
end, {})

-- Custom command to list the pinned buffers
vim.api.nvim_create_user_command("Ps", function()
  local pinned = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].pinned then
      table.insert(pinned, bufnr)
    end
  end
    if #pinned == 0 then
      vim.notify("No pinned buffers", vim.log.levels.INFO)
      return
    end
  table.sort(pinned, function(a, b)
    return vim.b[a].pin_number < vim.b[b].pin_number
  end)
  for _, bufnr in ipairs(pinned) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    local relative_name = vim.fn.fnamemodify(name, ":.")
    print(vim.b[bufnr].pin_number .. " " .. relative_name)
  end
end, {})

-- Custom command to jump to the pinned buffer by pin number
vim.api.nvim_create_user_command("P", function(opts)
  local pin_number = tonumber(opts.args)
  if not pin_number then
    vim.notify("Usage: :P <number>", vim.log.levels.ERROR)
    return
  end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr)
        and vim.b[bufnr].pinned
        and vim.b[bufnr].pin_number == pin_number then
      vim.api.nvim_set_current_buf(bufnr)
      return
    end
  end
  vim.notify("No pinned buffer " .. pin_number, vim.log.levels.WARN)
end, {
  nargs = 1,
})

