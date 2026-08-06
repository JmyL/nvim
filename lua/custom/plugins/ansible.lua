return {
  {
    'pearofducks/ansible-vim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('ansible').setup()
      -- ansible-vim sets *.j2 to jinja2; reuse the jinja treesitter parser.
      vim.treesitter.language.register('jinja', 'jinja2')
    end,
  },
}
