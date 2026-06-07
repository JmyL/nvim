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

local osc52 = require 'vim.ui.clipboard.osc52'

local function paste_with_tmux_refresh(reg)
  return function()
    if vim.env.TMUX then
      vim.fn.system { 'tmux', 'refresh-client', '-l' }
      vim.uv.sleep(100)
    end
    return osc52.paste(reg)()
  end
end

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = osc52.copy '+',
    ['*'] = osc52.copy '*',
  },
  paste = {
    ['+'] = paste_with_tmux_refresh '+',
    ['*'] = paste_with_tmux_refresh '*',
  },
}

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
