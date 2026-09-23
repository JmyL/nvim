return {
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local incline = require 'incline'

      -- 하이라이트 그룹 정의 및 테마 변경 시 자동 재적용 설정
      local function set_incline_highlights()
        -- MiniStatuslineModeNormal의 배경색을 가져와서 활성 창의 배경색으로 사용하고, 글씨는 흰색(#ffffff)으로 고정
        local normal_status = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineModeNormal' })
        local bg_color = normal_status.bg or normal_status.background or '#89b4fa' -- fallback to catppuccin blue
        
        -- MiniStatuslineDevinfo의 배경색과 글씨색을 가져와서 비활성 창에 적용
        local devinfo_status = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo' })
        local inactive_bg = devinfo_status.bg or devinfo_status.background or '#363a4f'
        local inactive_fg = devinfo_status.fg or devinfo_status.foreground or '#cad3f5'

        vim.api.nvim_set_hl(0, 'InclineNormalActive', {
          bg = bg_color,
          fg = '#ffffff', -- 흰색 글씨 고정
        })

        vim.api.nvim_set_hl(0, 'InclineNormalInactive', {
          bg = inactive_bg,
          fg = inactive_fg,
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
          local text_style = is_focused and { gui = 'bold' } or { gui = 'none' }

          -- padding = 1이 자동으로 좌우 여백을 주므로, 문자열 앞뒤의 수동 공백을 제거하여 정렬 불균형 및 @ 표시 방지
          return {
            { icon .. rel_path .. flags, text_style },
          }
        end,
      }
    end,
  },
}
