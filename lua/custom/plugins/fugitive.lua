return {
  {
    'tpope/vim-fugitive',
    lazy = false,
    keys = {
      { '<leader>gs', ':0Git<CR>', desc = '[G]it [s]tatus' },
    },
    silent = true,
    config = function()
      -- Fixed-width author so :Gclog subjects stay aligned.
      vim.g.fugitive_summary_format = '%<(20,trunc)%an %s'

      local git_status_cursors = {}

      local group = vim.api.nvim_create_augroup('fugitive_cursor_restore', { clear = true })

      -- Fugitive's <CR> is Gedit, which calls BlurStatus: leave the status
      -- window, or :new a split if there is no other usable window. :0Git
      -- already occupies the current window; open the file there instead.
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'fugitive',
        callback = function()
          vim.keymap.set('n', '<CR>', function()
            pcall(vim.api.nvim_win_del_var, 0, 'fugitive_status')
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>fugitive:<CR>', true, false, true), 'm', false)
          end, { buffer = true, silent = true, desc = 'Open file in current window' })
        end,
      })

      vim.api.nvim_create_autocmd('BufLeave', {
        group = group,
        pattern = 'fugitive://*.git//',
        callback = function()
          local bufname = vim.fn.bufname()
          git_status_cursors[bufname] = vim.fn.line '.'
        end,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        pattern = 'fugitive://*.git//',
        callback = function()
          local bufname = vim.fn.bufname()
          if git_status_cursors[bufname] then
            vim.cmd('normal! ' .. git_status_cursors[bufname] .. 'G')
          end
        end,
      })
    end,
  },
}
