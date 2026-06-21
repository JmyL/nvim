-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'options'
require 'keymaps'
require 'filetypes'
require 'lazy-bootstrap'
require 'lazy-plugins'

-- Use open-url wrapper when available, otherwise fall back to xdg-open.
-- This keeps gx working both inside and outside toolbox/container.
vim.ui.open = function(url)
  local open_url = vim.fn.expand('$HOME/.local/bin/open-url')
  if vim.fn.executable(open_url) == 1 then
    vim.fn.jobstart({ open_url, url }, { detach = true })
  else
    vim.fn.jobstart({ 'xdg-open', url }, { detach = true })
  end
end

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.asc',
  callback = function()
    vim.bo.filetype = 'asc'
    vim.cmd [[
      syntax match AscHttpsUrl /https:\/\/\S\+/ conceal cchar=🔗
      setlocal conceallevel=2
    ]]
    vim.keymap.set('n', 'gX', function()
      local line = vim.api.nvim_get_current_line()
      local url = line:match 'https://%S+'
      if url then
        vim.ui.open(url)
      else
        print 'No URL found under cursor'
      end
    end, { buffer = true })
  end,
})
-- require 'config.terminal'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
