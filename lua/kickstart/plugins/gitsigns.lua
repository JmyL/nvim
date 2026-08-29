-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    enabled = true,
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buf = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>gp', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [p]ut hunk' })
        map('v', '<leader>gg', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [g]et hunk' })
        -- normal mode
        map('n', '<leader>gp', gitsigns.stage_hunk, { desc = '[G]it [P]ut hunk' })
        map('n', '<leader>gg', gitsigns.reset_hunk, { desc = '[G]it [G]et hunk' })
        map('n', '<leader>gP', gitsigns.stage_buffer, { desc = '[G]it [S]tage buffer' })
        map('n', '<leader>gG', gitsigns.reset_buffer, { desc = '[G]it [R]eset buffer' })
        map('n', '<leader>gu', gitsigns.stage_hunk, { desc = '[G]it [U]ndo stage hunk' })
        map('n', '<leader>go', gitsigns.preview_hunk, { desc = '[G]it Pre[v]iew hunk' })
        map('n', '<leader>gb', gitsigns.blame_line, { desc = '[G]it [b]lame line' })
        map('n', '<leader>gd', gitsigns.diffthis, { desc = '[G]it [d]iff against index' })
        map('n', '<leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = '[G]it [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>gb', gitsigns.toggle_current_line_blame, { desc = 'Toggle [G]it show [b]lame line' })
        map('n', '<leader>gv', gitsigns.preview_hunk_inline, { desc = 'Toggle [G]it show [D]eleted' })
      end,
    },
  },
}
