return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ft = { 'markdown', 'codecompanion' },
    keys = {
      {
        '<leader>tm',
        function()
          require('render-markdown').buf_toggle()
          local enabled = require('render-markdown.state').get(0).enabled
          vim.notify('Markdown render (buffer): ' .. (enabled and 'on' or 'off'))
        end,
        desc = '[T]oggle [m]arkdown render (buffer)',
      },
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      completions = { blink = { enabled = true } },
      file_types = { 'markdown', 'codecompanion' },
      anti_conceal = {
        ignore = {
          head_background = true,
        },
      },
    },
  },
}
