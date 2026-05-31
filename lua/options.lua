-- For more options, you can see `:help option-list`
vim.o.scrollback = 100000
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
-- Sync clipboard between OS and Neovim.
-- Locally, use xsel so normal `p` can paste from the system clipboard.
-- Avoid GUI clipboard tools over SSH, and do not use wl-clipboard because
-- wl-paste can cause terminal resize issues in this environment.
local paste_from_unnamed = function()
  return { vim.fn.getreg('"', 1, true), vim.fn.getregtype '"' }
end

if not vim.env.SSH_CONNECTION and vim.fn.executable 'xsel' == 1 then
  vim.g.clipboard = {
    name = 'xsel',
    copy = {
      ['+'] = 'xsel --nodetach -ib',
      ['*'] = 'xsel --nodetach -ip',
    },
    paste = {
      ['+'] = 'xsel -ob',
      ['*'] = 'xsel -op',
    },
    cache_enabled = true,
  }
elseif vim.env.TMUX then
  -- In tmux, ask tmux to write its buffer to the terminal/system clipboard.
  -- Pasting falls back to Neovim's unnamed register because tmux/OSC52 cannot
  -- generally read the terminal clipboard.
  vim.g.clipboard = {
    name = 'tmux-load-buffer',
    copy = {
      ['+'] = 'tmux load-buffer -w -',
      ['*'] = 'tmux load-buffer -w -',
    },
    paste = {
      ['+'] = paste_from_unnamed,
      ['*'] = paste_from_unnamed,
    },
  }
else
  vim.g.clipboard = {
    name = 'osc52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
      ['+'] = paste_from_unnamed,
      ['*'] = paste_from_unnamed,
    },
  }
end

vim.opt.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.wrapscan = false
vim.o.linebreak = true
