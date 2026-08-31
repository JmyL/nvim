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
