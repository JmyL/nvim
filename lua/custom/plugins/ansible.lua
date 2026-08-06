return {
  {
    'pearofducks/ansible-vim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('ansible').setup()
      require('config.jinja_templates').setup()
    end,
  },
}
