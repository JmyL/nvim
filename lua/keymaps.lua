-- basic
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>C', '"_c$', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>c', '"_c', { noremap = true, silent = true })
vim.keymap.set('n', '<M-.>', '@@', { noremap = true, silent = true })

-- windows
-- vim.keymap.set('n', '<A-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<A-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>wk', 'gt', { desc = 'Move focus to the next tab' })
vim.keymap.set('n', '<leader>wl', 'gT', { desc = 'Move focus to the next tab' })
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
local function git_relpath()
  local abs = vim.fn.expand '%:p'
  if abs == '' then
    local name = vim.fn.expand '%'
    return name ~= '' and name or '[No Name]'
  end
  local dir = vim.fn.expand '%:p:h'
  local root = vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })[1]
  if vim.v.shell_error == 0 and root and abs:sub(1, #root) == root then
    return abs:sub(#root + 2)
  end
  return vim.fn.expand '%'
end

local function visual_line_range()
  local start_line, end_line = vim.fn.line 'v', vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return start_line, end_line
end

local function cite(path, start_line, end_line)
  if start_line == end_line then
    return string.format('%s:%d', path, start_line)
  end
  return string.format('%s:%d-%d', path, start_line, end_line)
end

local function copy_plus(text, message)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
  vim.notify(message, vim.log.levels.INFO)
end

local function yank_cite(start_line, end_line)
  local text = cite(git_relpath(), start_line, end_line)
  copy_plus(text, 'Copied ' .. text)
end

local function yank_snippet(start_line, end_line)
  local header = cite(git_relpath(), start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local ft = vim.bo.filetype
  local fence = ft ~= '' and ('```' .. ft) or '```'
  local text = table.concat({
    header,
    fence,
    table.concat(lines, '\n'),
    '```',
  }, '\n')
  copy_plus(text, 'Copied ' .. header)
end

vim.keymap.set('n', 'yc', '0y$', { desc = 'Yank line without newline' })

vim.keymap.set('n', '<leader>yf', function()
  local filepath = vim.fn.expand '%:p'
  copy_plus(filepath, 'File path copied: ' .. filepath)
end, { noremap = true, silent = true, desc = '[y]ank [f]ile path' })

vim.keymap.set('n', '<leader>yn', function()
  local filename = vim.fn.expand '%:t'
  copy_plus(filename, 'File name copied: ' .. filename)
end, { noremap = true, silent = true, desc = '[y]ank file [n]ame' })

vim.keymap.set('n', '<leader>ys', function()
  local filestem = vim.fn.expand '%:t:r'
  copy_plus(filestem, 'File stem copied: ' .. filestem)
end, { noremap = true, silent = true, desc = '[y]ank file [s]tem' })

vim.keymap.set('n', '<leader>yd', function()
  local filedir = vim.fn.expand '%:p:h'
  copy_plus(filedir, 'Directory path copied: ' .. filedir)
end, { noremap = true, silent = true, desc = '[y]ank [d]irectory' })

vim.keymap.set('n', '<leader>yg', function()
  local relative = git_relpath()
  copy_plus(relative, 'Relative path copied: ' .. relative)
end, { noremap = true, silent = true, desc = '[y]ank [g]it-relative path' })

vim.keymap.set('n', '<leader>yc', function()
  local line = vim.fn.line '.'
  yank_cite(line, line)
end, { noremap = true, silent = true, desc = '[y]ank [c]ite (path:line)' })

vim.keymap.set('v', '<leader>yc', function()
  yank_cite(visual_line_range())
end, { noremap = true, silent = true, desc = '[y]ank [c]ite (path:line)' })

vim.keymap.set('n', '<leader>ya', function()
  local line = vim.fn.line '.'
  yank_snippet(line, line)
end, { noremap = true, silent = true, desc = '[y]ank [a]gent snippet' })

vim.keymap.set('v', '<leader>ya', function()
  yank_snippet(visual_line_range())
end, { noremap = true, silent = true, desc = '[y]ank [a]gent snippet' })
