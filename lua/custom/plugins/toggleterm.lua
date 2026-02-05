return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<M-;>]],
      insert_mappings = false,
      start_in_insert = false,
      shade_terminals = true,
      shading_factor = -1,
      shading_ratio = -3,
    },
    init = function()
      vim.keymap.set('n', '<leader>ta', ':ToggleTermToggleAll<CR>', { desc = '[t]erminal - toggle [a]ll' })
      vim.keymap.set('n', '<leader>ts', ':TermSelect<CR>', { desc = '[t]erminal - [s]elect' })
      -- vim.keymap.set('n', '<leader>tn', function()
      --   if vim.bo.filetype == 'toggleterm' then
      --     vim.ui.input({ prompt = 'Set terminal name: ' }, function(input)
      --       if name ~= '' then
      --         local term = select(2, require('toggleterm.terminal').identify())
      --         require('toggleterm').set_term_name(name, term)
      --       end
      --     end)
      --   end
      -- end, { desc = '[t]erminal - set [n]ame' })
    end,
  },
}
