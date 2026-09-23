return {
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local incline = require 'incline'

      -- 하이라이트 그룹 정의 및 테마 변경 시 자동 재적용 설정
      local function get_hl_colors(name)
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        local fg = hl.fg or hl.foreground
        local bg = hl.bg or hl.background
        if hl.reverse then
          return bg, fg
        end
        return fg, bg
      end

      local function hex_color(color, fallback)
        if type(color) == 'number' then
          return string.format('#%06x', color)
        end
        return color or fallback
      end

      local function set_incline_highlights()
        local _, normal_bg = get_hl_colors('MiniStatuslineModeNormal')
        local devinfo_fg, devinfo_bg = get_hl_colors('MiniStatuslineDevinfo')

        -- 활성 창: 배경은 statusline NORMAL 배경(파랑), 글씨는 무조건 흰색(#ffffff)
        vim.api.nvim_set_hl(0, 'InclineNormalActive', {
          bg = hex_color(normal_bg, '#89b4fa'),
          fg = '#ffffff',
          bold = true,
        })

        -- 비활성 창: statusline Git 영역과 동일한 연회색 배경 + 진회색 글씨
        vim.api.nvim_set_hl(0, 'InclineNormalInactive', {
          bg = hex_color(devinfo_bg, '#363a4f'),
          fg = hex_color(devinfo_fg, '#cad3f5'),
        })
      end

      set_incline_highlights()

      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = set_incline_highlights,
      })

      incline.setup {
        window = {
          padding = 1,
          placement = { horizontal = 'right', vertical = 'bottom' }, -- 창의 우측 하단에 배치
          margin = { horizontal = 0, vertical = 1 }, -- horizontal을 0으로 변경하여 우측 끝에 딱 붙임
          winhighlight = {
            active = { Normal = 'InclineNormalActive' },
            inactive = { Normal = 'InclineNormalInactive' },
          },
        },
        render = function(props)
          local bufname = vim.api.nvim_buf_get_name(props.buf)
          if bufname == '' then
            return { { ' [No Name] ', group = 'Title' } }
          end

          -- 상대 경로 가져오기
          local rel_path = vim.fn.fnamemodify(bufname, ':.')

          -- 수정 여부 및 읽기 전용 표시
          local modified = vim.api.nvim_get_option_value('modified', { buf = props.buf })
          local readonly = vim.api.nvim_get_option_value('readonly', { buf = props.buf })
          local flags = ''
          if modified then
            flags = ' [+]'
          end
          if readonly then
            flags = flags .. ' [RO]'
          end

          -- 파일 아이콘 가져오기
          local icon = ''
          local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
          if has_devicons then
            local filename = vim.fn.fnamemodify(bufname, ':t')
            local ext = vim.fn.fnamemodify(filename, ':e')
            local icon_str = devicons.get_icon(filename, ext, { default = true })
            if icon_str then
              icon = icon_str .. ' '
            end
          end

          -- 활성화된 창과 비활성화된 창의 텍스트 스타일 조정
          local is_focused = props.focused
          local text_style = {
            gui = is_focused and 'bold' or 'none',
            guifg = is_focused and '#ffffff' or '#363a4f',
          }

          -- highlight 속성은 텍스트 조각 자체에 지정해야 파일명과 아이콘 모두에 적용된다.
          return {
            {
              icon .. rel_path .. flags,
              gui = text_style.gui,
              guifg = text_style.guifg,
            },
          }
        end,
      }
    end,
  },
}
