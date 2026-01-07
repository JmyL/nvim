-- basic
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>C', '"_c$', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>c', '"_c', { noremap = true, silent = true })
vim.keymap.set('n', '<M-.>', '@@', { noremap = true, silent = true })

-- windows
vim.keymap.set('n', '<A-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<A-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>wk', 'gt', { desc = 'Move focus to the next tab' })
vim.keymap.set('n', '<leader>wl', 'gT', { desc = 'Move focus to the next tab' })
vim.keymap.set('n', '<A-S-l>', '<cmd> vertical resize +5 <cr>', { desc = 'Vertical resize +5' })
vim.keymap.set('n', '<A-S-h>', '<cmd> vertical resize -5 <cr>', { desc = 'Vertical resize -5' })
vim.keymap.set('n', '<A-S-k>', '<cmd> horizontal resize +2 <cr>', { desc = 'Horizontal resize +2' })
vim.keymap.set('n', '<A-S-j>', '<cmd> horizontal resize -2 <cr>', { desc = 'Vwertical resize -2' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Maximize current window' })
vim.keymap.set('n', '<leader>wt', '<cmd>tab split<CR>', { desc = 'Create new [T]ab' })

-- others
vim.keymap.set('n', '<leader>;', ':', { desc = 'enter command mode' })
vim.keymap.set('n', '<C-q>', '<cmd>q<CR>', { desc = 'Close window' })
vim.keymap.set('i', '<C-q>', '<Esc><cmd>q<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>h', '<cmd>LspClangdSwitchSourceHeader<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>x', '<cmd>.lua<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>x', "<cmd>'<,'>lua<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader>X', ':%lua<CR>', { noremap = true, silent = true })

-- clipboard
vim.keymap.set('n', '<leader>yf', function()
  local filepath = vim.fn.expand '%:p'
  vim.fn.setreg('+', filepath)
  vim.notify('File path copied: ' .. filepath, vim.log.levels.INFO)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>yn', function()
  local filename = vim.fn.expand '%:t'
  vim.fn.setreg('+', filename)
  vim.notify('File name copied: ' .. filename, vim.log.levels.INFO)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ys', function()
  local filestem = vim.fn.expand '%:t:r'
  vim.fn.setreg('+', filestem)
  vim.notify('File stem copied: ' .. filestem, vim.log.levels.INFO)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>yd', function()
  local filedir = vim.fn.expand '%:p:h'
  vim.fn.setreg('+', filedir)
  vim.notify('Directory path copied: ' .. filedir, vim.log.levels.INFO)
end, { noremap = true, silent = true })
