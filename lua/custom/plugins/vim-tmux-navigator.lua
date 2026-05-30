return {
  {
    'christoomey/vim-tmux-navigator',
    init = function()
      vim.g.tmux_navigator_no_wrap = 1
    end,
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<a-h>', '<cmd>TmuxNavigateLeft<cr>' },
      { '<a-j>', '<cmd>TmuxNavigateDown<cr>' },
      { '<a-k>', '<cmd>TmuxNavigateUp<cr>' },
      { '<a-l>', '<cmd>TmuxNavigateRight<cr>' },
      { '<a-t>', '<cmd>TmuxNavigatePrevious<cr>' },
    },
  },
}
