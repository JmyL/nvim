return {
  {
    'nullromo/go-up.nvim',
    lazy = false,
    opts = {
      -- Needed so last-line bottom-align can stick; otherwise scrolloff=10 pulls the view back.
      respectScrolloff = false,
      ignoredFiletypes = {
        'aerial',
        'codecompanion',
        'fugitive',
        'fugitiveblame',
        'lazy',
        'mason',
        'neo-tree',
        'oil',
        'TelescopePrompt',
        'toggleterm',
      },
    },
    config = function(_, opts)
      local go_up = require 'go-up'
      go_up.setup(opts)

      -- Plugin only enables scrolling past line 1; pin short buffers to the window bottom.
      vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinResized' }, {
        group = vim.api.nvim_create_augroup('go-up-align-bottom', { clear = true }),
        desc = 'Go-Up: pin short buffers to the bottom of the window',
        callback = function()
          vim.schedule(go_up.alignBottom)
        end,
      })
    end,
  },
}
