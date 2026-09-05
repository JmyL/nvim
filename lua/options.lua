-- For more options, you can see `:help option-list`
vim.o.scrollback = 100000
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
-- Sync clipboard between OS and Neovim.
-- Locally, use xsel so normal `p` can paste from the system clipboard.
-- In Herdr, use wl-paste for paste because Herdr does not answer OSC52 read
-- queries. For copy/yank, call the real wl-copy directly so it does not go
-- through ~/.local/bin/wl-copy, which dedents Herdr copy-mode text.

local osc52 = require 'vim.ui.clipboard.osc52'

local function is_herdr()
  return vim.env.HERDR_PANE_ID ~= nil or vim.env.HERDR_TAB_ID ~= nil or vim.env.HERDR_WORKSPACE_ID ~= nil
end

local function is_aerc()
  return vim.env.AERC_ACCOUNT ~= nil
end

local function wl_paste(reg)
  -- wl-paste appends a newline unless --no-newline is set; Neovim's
  -- builtin provider uses the same flag so `p` stays characterwise.
  local cmd = { 'wl-paste', '--no-newline', '--type', 'text/plain;charset=utf-8' }
  if reg == '*' then
    table.insert(cmd, '--primary')
  end

  local lines = vim.fn.systemlist(cmd, '', 1)
  if vim.v.shell_error ~= 0 then
    return { { '' }, 'v' }
  end
  local regtype = (#lines > 0 and lines[#lines] == '') and 'V' or 'v'
  return { lines, regtype }
end

local function real_wl_copy()
  for _, path in ipairs { '/usr/bin/wl-copy', '/bin/wl-copy' } do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  return nil
end

local function wl_copy(reg)
  return function(lines, regtype)
    local cmd = { real_wl_copy(), '--type', 'text/plain;charset=utf-8' }
    if cmd[1] == nil then
      return osc52.copy(reg)(lines, regtype)
    end
    if reg == '*' then
      table.insert(cmd, '--primary')
    end

    local text = table.concat(lines, '\n')
    if regtype == 'V' then
      text = text .. '\n'
    end
    vim.fn.system(cmd, text)
  end
end

local function copy_with_tmux_or_herdr(reg)
  return function(lines, regtype)
    if is_herdr() then
      return wl_copy(reg)(lines, regtype)
    end
    return osc52.copy(reg)(lines, regtype)
  end
end

local function paste_with_tmux_or_herdr(reg)
  return function()
    if (is_herdr() or is_aerc()) and vim.fn.executable 'wl-paste' == 1 then
      return wl_paste(reg)
    end

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
    ['+'] = copy_with_tmux_or_herdr '+',
    ['*'] = copy_with_tmux_or_herdr '*',
  },
  paste = {
    ['+'] = paste_with_tmux_or_herdr '+',
    ['*'] = paste_with_tmux_or_herdr '*',
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

-- Hide tab glyphs when the buffer uses real tabs for indent; keep them
-- visible in expandtab buffers so accidental tabs still stand out.
local function update_listchars()
  if vim.bo.expandtab then
    vim.opt_local.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  else
    vim.opt_local.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
  end
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'OptionSet' }, {
  callback = function(args)
    if args.event == 'OptionSet' and args.match ~= 'expandtab' then
      return
    end
    update_listchars()
  end,
})
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.wrapscan = false
vim.o.linebreak = true
