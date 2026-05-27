return {
  {
    'github/copilot.vim',
    enable = false,
    lazy = true,
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
    end,
  },
}
