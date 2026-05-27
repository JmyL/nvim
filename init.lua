-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'options'
require 'keymaps'
require 'filetypes'
require 'lazy-bootstrap'
require 'lazy-plugins'

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
        vim.fn.jobstart({ 'xdg-open', url }, { detach = true })
      else
        print 'No URL found under cursor'
      end
    end, { buffer = true })
  end,
})
-- require 'config.terminal'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
