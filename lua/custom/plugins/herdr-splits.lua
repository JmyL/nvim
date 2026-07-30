return {
  {
    'lmilojevicc/herdr-splits.nvim',
    -- or local path during development:
    -- dir = '~/Projects/herdr-splits',
    cond = vim.env.HERDR_ENV == '1',
    event = 'VeryLazy',
    -- Optional: auto-sync the Herdr-side scripts when lazy updates this plugin.
    -- Requires `auto_sync_herdr = true` in setup() below to take effect.
    -- lazy.nvim: strings without a leading ':' run as shell; use ':' for Lua.
    build = ':lua require("herdr-splits").sync_herdr()',
    config = function()
      require('herdr-splits').setup {
        -- Defaults shown. All fields optional.
        default_amount = 0.03, -- Herdr resize ratio
        neovim_amount = 3, -- Neovim resize cells
        at_edge = 'stop', -- 'wrap' | 'stop' | 'split' | function
        -- ignored_buftypes = { 'nofile', 'quickfix', 'prompt' },
        -- ignored_filetypes = { 'NvimTree' },
        move_cursor_same_row = false,
        herdr_bin = nil, -- auto-detected from HERDR_BIN_PATH
        auto_sync_herdr = true, -- opt-in: sync Herdr-side scripts on update
        nav_at_edge = 'stop',
        nav_keys = { left = '<M-h>', down = '<M-j>', up = '<M-k>', right = '<M-l>' },
        resize_keys = { left = '<M-S-h>', down = '<M-S-j>', up = '<M-S-k>', right = '<M-S-l>' },
      }
    end,
    keys = {
      {
        '<M-h>',
        function()
          require('herdr-splits').move_cursor_left()
        end,
        desc = 'Navigate left',
      },
      {
        '<M-j>',
        function()
          require('herdr-splits').move_cursor_down()
        end,
        desc = 'Navigate down',
      },
      {
        '<M-k>',
        function()
          require('herdr-splits').move_cursor_up()
        end,
        desc = 'Navigate up',
      },
      {
        '<M-l>',
        function()
          require('herdr-splits').move_cursor_right()
        end,
        desc = 'Navigate right',
      },
      {
        '<M-S-h>',
        function()
          require('herdr-splits').resize_left()
        end,
        desc = 'Resize left',
      },
      {
        '<M-S-j>',
        function()
          require('herdr-splits').resize_down()
        end,
        desc = 'Resize down',
      },
      {
        '<M-S-k>',
        function()
          require('herdr-splits').resize_up()
        end,
        desc = 'Resize up',
      },
      {
        '<M-S-l>',
        function()
          require('herdr-splits').resize_right()
        end,
        desc = 'Resize right',
      },
    },
  },
}
