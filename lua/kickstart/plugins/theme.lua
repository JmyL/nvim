return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      local mode_file = vim.fn.expand '~/.cache/darkman/mode.txt'
      local cache_dir = vim.fn.fnamemodify(mode_file, ':h')

      local function background_from_darkman()
        local file = io.open(mode_file, 'r')
        if not file then
          return 'dark'
        end
        local mode = (file:read '*l' or ''):gsub('%s+$', '')
        file:close()
        if mode == 'light' then
          return 'light'
        end
        return 'dark'
      end

      local function apply_background()
        local background = background_from_darkman()
        if vim.o.background ~= background then
          vim.o.background = background
        end
        vim.cmd.colorscheme 'catppuccin'
      end

      require('catppuccin').setup {
        flavour = 'auto',
        background = {
          light = 'latte',
          dark = 'macchiato',
        },
      }

      vim.o.background = background_from_darkman()
      vim.cmd.colorscheme 'catppuccin'

      vim.uv.fs_mkdir(cache_dir, 448)
      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(
          cache_dir,
          {},
          vim.schedule_wrap(function(err, filename)
            if err then
              return
            end
            if filename == nil or filename == 'mode.txt' then
              apply_background()
            end
          end)
        )
      end
    end,
  },
}
-- { -- You can easily change to a different colorscheme.
--   -- Change the name of the colorscheme plugin below, and then
--   -- change the command in the config to whatever the name of that colorscheme is.
--   --
--   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--   'EdenEast/nightfox.nvim',
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   config = function()
--     ---@diagnostic disable-next-line: missing-fields
--     require('nightfox').setup {
--       styles = {
--         comments = { italic = false }, -- Disable italics in comments
--       },
--     }
--
--     -- Load the colorscheme here.
--     -- Like many other themes, this one has different styles, and you could load
--     -- any other, such as 'nightfox', 'dayfox', 'dawnfox', 'duskfox', 'nordfox', 'terafox', 'carbonfox'.
--     vim.cmd.colorscheme 'nordfox'
--   end,
-- },
