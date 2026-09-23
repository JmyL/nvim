return {
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local incline = require 'incline'
      incline.setup {
        window = {
          padding = 1,
          placement = { horizontal = 'right', vertical = 'bottom' }, -- 창의 우측 하단에 배치
          margin = { horizontal = 1, vertical = 1 },
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
          local icon_color = nil
          if has_devicons then
            local filename = vim.fn.fnamemodify(bufname, ':t')
            local ext = vim.fn.fnamemodify(filename, ':e')
            local icon_str, color = devicons.get_icon_color(filename, ext, { default = true })
            if icon_str then
              icon = icon_str .. ' '
              icon_color = color
            end
          end

          -- 활성화된 창과 비활성화된 창의 텍스트 스타일 조정
          local is_focused = props.focused
          local text_style = is_focused and { gui = 'bold' } or { gui = 'none' }

          return {
            { icon, guifg = icon_color },
            { rel_path .. flags, text_style },
          }
        end,
      }
    end,
  },
}
