return {
  'stevearc/aerial.nvim',
  opts = {
    on_attach = function(bufnr)
      vim.keymap.set('n', '<C-{>', '<cmd>AerialPrev<CR>', { buf = bufnr })
      vim.keymap.set('n', '<C-}>', '<cmd>AerialNext<CR>', { buf = bufnr })
    end,
  },
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>v', '<cmd>AerialToggle left<CR>', desc = 'Toggle Aerial' },
  },
}
