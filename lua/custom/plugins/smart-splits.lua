local tmux_swap_script = vim.fn.expand '~/.tmux/scripts/swap-pane-direction'

local function has_nvim_win(direction)
  local wincmd = ({ left = 'h', down = 'j', up = 'k', right = 'l' })[direction]
  local cur = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. wincmd)
  local moved = vim.api.nvim_get_current_win() ~= cur
  vim.api.nvim_set_current_win(cur)
  return moved
end

local function swap_or_tmux(direction)
  if has_nvim_win(direction) then
    local smart_splits = require 'smart-splits'
    local swaps = {
      left = smart_splits.swap_buf_left,
      down = smart_splits.swap_buf_down,
      up = smart_splits.swap_buf_up,
      right = smart_splits.swap_buf_right,
    }
    swaps[direction]({ move_cursor = true })
    return
  end

  if vim.env.TMUX and vim.fn.executable 'tmux' == 1 then
    vim.fn.jobstart({ 'tmux', 'run-shell', tmux_swap_script .. ' ' .. direction }, { detach = true })
  end
end

return {
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    keys = {
      -- resize splits
      {
        '<A-S-h>',
        function()
          require('smart-splits').resize_left()
        end,
        desc = 'Resize split left',
      },
      {
        '<A-S-j>',
        function()
          require('smart-splits').resize_down()
        end,
        desc = 'Resize split down',
      },
      {
        '<A-S-k>',
        function()
          require('smart-splits').resize_up()
        end,
        desc = 'Resize split up',
      },
      {
        '<A-S-l>',
        function()
          require('smart-splits').resize_right()
        end,
        desc = 'Resize split right',
      },

      -- move between splits
      {
        '<A-h>',
        function()
          require('smart-splits').move_cursor_left()
        end,
        desc = 'Move to left split',
      },
      {
        '<A-j>',
        function()
          require('smart-splits').move_cursor_down()
        end,
        desc = 'Move to lower split',
      },
      {
        '<A-k>',
        function()
          require('smart-splits').move_cursor_up()
        end,
        desc = 'Move to upper split',
      },
      {
        '<A-l>',
        function()
          require('smart-splits').move_cursor_right()
        end,
        desc = 'Move to right split',
      },

      -- swap buffers; when at a Neovim edge, swap tmux panes instead
      {
        '<C-M-h>',
        function()
          swap_or_tmux 'left'
        end,
        desc = 'Swap left or tmux pane left',
      },
      {
        '<C-M-j>',
        function()
          swap_or_tmux 'down'
        end,
        desc = 'Swap down or tmux pane down',
      },
      {
        '<C-M-k>',
        function()
          swap_or_tmux 'up'
        end,
        desc = 'Swap up or tmux pane up',
      },
      {
        '<C-M-l>',
        function()
          swap_or_tmux 'right'
        end,
        desc = 'Swap right or tmux pane right',
      },
    },
    opts = {
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = {
        'nofile',
        'quickfix',
        'prompt',
      },
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = {
        'NvimTree',
        'fugitiveblame',
        'aerial',
      },
      -- the default number of lines/columns to resize by at a time
      default_amount = 3,
      -- Desired behavior when your cursor is at an edge and you
      -- are moving towards that same edge:
      -- 'wrap' => Wrap to opposite side
      -- 'split' => Create a new split in the desired direction
      -- 'stop' => Do nothing
      -- function => You handle the behavior yourself
      -- NOTE: If using a function, the function will be called with
      -- a context object with the following fields:
      -- {
      --    mux = {
      --      type:'tmux'|'wezterm'|'kitty'|'zellij'
      --      current_pane_id():number,
      --      is_in_session(): boolean
      --      current_pane_is_zoomed():boolean,
      --      -- following methods return a boolean to indicate success or failure
      --      current_pane_at_edge(direction:'left'|'right'|'up'|'down'):boolean
      --      next_pane(direction:'left'|'right'|'up'|'down'):boolean
      --      resize_pane(direction:'left'|'right'|'up'|'down'):boolean
      --      split_pane(direction:'left'|'right'|'up'|'down',size:number|nil):boolean
      --    },
      --    direction = 'left'|'right'|'up'|'down',
      --    split(), -- utility function to split current Neovim pane in the current direction
      --    wrap(), -- utility function to wrap to opposite Neovim pane
      -- }
      -- NOTE: `at_edge = 'wrap'` is not supported on Kitty terminal
      -- multiplexer, as there is no way to determine layout via the CLI
      at_edge = 'stop',
      -- Desired behavior when the current window is floating:
      -- 'previous' => Focus previous Vim window and perform action
      -- 'mux' => Always forward action to multiplexer
      float_win_behavior = 'previous',
      -- when moving cursor between splits left or right,
      -- place the cursor on the same row of the *screen*
      -- regardless of line numbers. False by default.
      -- Can be overridden via function parameter, see Usage.
      move_cursor_same_row = false,
      -- whether the cursor should follow the buffer when swapping
      -- buffers by default; it can also be controlled by passing
      -- `{ move_cursor = true }` or `{ move_cursor = false }`
      -- when calling the Lua function.
      cursor_follows_swapped_bufs = false,
      -- ignore these autocmd events (via :h eventignore) while processing
      -- smart-splits.nvim computations, which involve visiting different
      -- buffers and windows. These events will be ignored during processing,
      -- and un-ignored on completed. This only applies to resize events,
      -- not cursor movement events.
      ignored_events = {
        'BufEnter',
        'WinEnter',
      },
      -- enable or disable a multiplexer integration;
      -- automatically determined, unless explicitly disabled or set,
      -- by checking the $TERM_PROGRAM environment variable,
      -- and the $KITTY_LISTEN_ON environment variable for Kitty.
      -- You can also set this value by setting `vim.g.smart_splits_multiplexer_integration`
      -- before the plugin is loaded (e.g. for lazy environments).
      multiplexer_integration = nil,
      -- disable multiplexer navigation if current multiplexer pane is zoomed
      -- NOTE: This does not work on Zellij as there is no way to determine the
      -- pane zoom state outside of the Zellij Plugin API, which does not apply here
      disable_multiplexer_nav_when_zoomed = true,
      -- Supply a Kitty remote control password if needed,
      -- or you can also set vim.g.smart_splits_kitty_password
      -- see https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remote_control_password
      kitty_password = nil,
      -- In Zellij, set this to true if you would like to move to the next *tab*
      -- when the current pane is at the edge of the zellij tab/window
      zellij_move_focus_or_tab = false,
      -- default logging level, one of: 'trace'|'debug'|'info'|'warn'|'error'|'fatal'
      log_level = 'info',
    },
  },
}
