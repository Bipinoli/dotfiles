vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.number = true

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


-- Toggle Location List
vim.keymap.set('n', '<leader>l', function()
  local loc_open = false
  -- Loop through all windows to see if any has a location list open
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.loclist == 1 then
      loc_open = true
      break
    end
  end
  if loc_open then
    vim.cmd('lclose')
  else
    vim.cmd('lopen')
    vim.cmd('resize 30')
  end
end, { noremap = true, silent = true })


-- Fuzzy file finding of a git tracked files
vim.keymap.set('n', '<leader>f', function()
  local fzf = io.popen('fd --type f | fzf --preview "bat --style=numbers --color=always {}"'):read('*a')
  fzf = fzf:gsub("\n","")  -- remove newline
  if fzf ~= "" then
    vim.cmd('edit ' .. fzf)
  end
end, { noremap = true, silent = true })

