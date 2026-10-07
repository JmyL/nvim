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
      ignore = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        if name == '' then
          return false
        end
        local vault = vim.fs.normalize '~/Documents/Obsidian'
        return name:find('^' .. vim.pesc(vault) .. '/') ~= nil
      end,
      completions = { blink = { enabled = true } },
      file_types = { 'markdown', 'codecompanion' },
      html = {
        comment = {
          conceal = false,
        },
      },
      anti_conceal = {
        ignore = {
          head_background = true,
        },
      },
    },
  },
}
