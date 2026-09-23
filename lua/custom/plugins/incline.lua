return {
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local incline = require 'incline'

      incline.setup {
        highlight = {
          groups = {
            InclineNormal = 'PmenuSel',
            InclineNormalNC = 'NormalFloat',
          },
        },
        window = {
          padding = 1,
          placement = { horizontal = 'right', vertical = 'bottom' }, -- 창의 우측 하단에 배치
          margin = { horizontal = 0, vertical = 1 }, -- horizontal을 0으로 변경하여 우측 끝에 딱 붙임
        },
        render = function(props)
          local bufname = vim.api.nvim_buf_get_name(props.buf)
          if bufname == '' then
            return ' [No Name] '
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

          return icon .. rel_path .. flags
        end,
      }
    end,
  },
}
