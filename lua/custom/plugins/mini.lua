return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  See https://github.com/echasnovski/mini.statusline/blob/main/doc/mini-statusline.txt
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- row:col (위치 정보) 제거
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return ''
      end

      -- 글로벌 statusline에서 파일명 제거 (incline.nvim이 각 창의 하단에 표시하므로). 단, 터미널(toggleterm)일 때는 표시.
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_filename = function()
        if vim.bo.filetype == 'toggleterm' then
          local base = 'terminal ' .. tostring(vim.b.toggle_number)
          local display_name = select(2, require('toggleterm.terminal').identify()).display_name
          if display_name ~= nil then
            return base .. ': ' .. display_name
          else
            return base
          end
        end
        return ''
      end
      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
      require('mini.operators').setup { replace = { prefix = '<leader>r' } }
    end,
  },
}
