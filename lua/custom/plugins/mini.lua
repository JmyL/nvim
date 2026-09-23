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
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
            local git = statusline.section_git { trunc_width = 80 }
            local diff = statusline.section_diff { trunc_width = 80 }
            local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
            local lsp = statusline.section_lsp { trunc_width = 75 }
            local filename = statusline.section_filename { trunc_width = 100 }
            local fileinfo = statusline.section_fileinfo { trunc_width = 90 }
            local location = statusline.section_location { trunc_width = 75 }
            local search = statusline.section_searchcount { trunc_width = 75 }

            return statusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { search, location } },
            }
          end,
        },
      }

      -- row:col (위치 정보) 제거
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return ''
      end

      -- 글로벌 statusline에서 파일명 표시 (현재 작업 디렉토리 기준 상대 경로 전체 표시)
      local orig_section_filename = MiniStatusline.section_filename
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_filename = function(args)
        if vim.bo.filetype == 'toggleterm' then
          local base = 'terminal ' .. tostring(vim.b.toggle_number)
          local display_name = select(2, require('toggleterm.terminal').identify()).display_name
          if display_name ~= nil then
            return base .. ': ' .. display_name
          else
            return base
          end
        end
        -- 원래 mini.statusline의 파일명 표시 로직을 호출하여 전체 상대 경로가 나오도록 함
        return orig_section_filename(args)
      end

      -- 각 창(window)의 상단에 파일 이름과 아이콘을 표시하는 custom winbar 설정
      _G.custom_winbar = function()
        local exclude_ft = {
          'neo-tree',
          'toggleterm',
          'help',
          'qf',
          'lazy',
          'mason',
          'aerial',
          'codecompanion',
        }

        if vim.tbl_contains(exclude_ft, vim.bo.filetype) or vim.bo.buftype ~= '' then
          return ''
        end

        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == '' then
          return ' [No Name]'
        end

        local filename = vim.fn.fnamemodify(bufname, ':t')

        -- 파일 아이콘 가져오기
        local icon = ''
        local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
        if has_devicons then
          local ext = vim.fn.fnamemodify(filename, ':e')
          local icon_str, _ = devicons.get_icon(filename, ext, { default = true })
          if icon_str then
            icon = icon_str .. ' '
          end
        end

        -- %m은 수정됨[+], %r은 읽기 전용[RO] 표시
        return ' ' .. icon .. filename .. ' %m%r'
      end

      vim.opt.winbar = '%{%v:lua.custom_winbar()%}'

      -- 비활성 창 winbar 글자를 더 흐리게 표시
      vim.api.nvim_set_hl(0, 'WinBarNC', { link = 'StatusLineNC' })
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
          vim.api.nvim_set_hl(0, 'WinBarNC', { link = 'StatusLineNC' })
        end,
      })

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
      require('mini.operators').setup { replace = { prefix = '<leader>r' } }
    end,
  },
}
