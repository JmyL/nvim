return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = false,
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    opts = {
      legacy_commands = false,

      ui = {
        enable = true,
        ignore_conceal_warn = true,
      },

      callbacks = {
        post_setup = function()
          local state = _G.Obsidian
          for _, workspace in ipairs(state and state.workspaces or {}) do
            require('obsidian.ui').setup(workspace, state.opts.ui)
          end
        end,
      },

      workspaces = {
        {
          name = 'personal',
          path = '~/Documents/Obsidian',
        },
      },
      -- other fields ...

      templates = {
        folder = 'Templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
      -- see below for full list of options 👇
    },
    init = function()
      local Snacks = require 'snacks'

      local function snack_input_and_execute(prompt_text, command_prefix)
        Snacks.input({
          prompt = prompt_text,
        }, function(input)
          if input and input ~= '' then
            vim.cmd(command_prefix .. ' ' .. vim.fn.shellescape(input))
          end
        end)
      end
      vim.keymap.set({ 'n', 'v' }, '<leader>oo', '<cmd>cd ~/Documents/Obsidian<CR> <cmd>Obsidian open<CR>', { desc = '[o]pen obsidian' })
      vim.keymap.set({ 'n', 'v' }, '<leader>oq', '<cmd>cd -<CR>', { desc = '[q]uit obsidian' })

      vim.keymap.set({ 'n', 'v' }, '<leader>ox', '<cmd>Obsidian toggle_checkbox<CR>', { desc = 'toggle checkbo[x]' })
      vim.keymap.set({ 'n' }, '<leader>oc', function()
        snack_input_and_execute('Enter title for new note:', 'Obsidian new')
      end, { desc = '[c]reate new note' })
      vim.keymap.set({ 'v' }, '<leader>oc', '<cmd>Obsidian link<CR>', { desc = '[c]onnect' })
      vim.keymap.set({ 'v' }, '<leader>oC', '<cmd>Obsidian link_new<CR>', { desc = '[C]reate and connect' })
      vim.keymap.set({ 'n', 'v' }, '<leader>oa', '<cmd>Obsidian template<CR>', { desc = '[a]pply template' })
      vim.keymap.set({ 'n', 'v' }, '<leader>os', '<cmd>Obsidian search<CR>', { desc = '[s]earch note' })
      vim.keymap.set({ 'n', 'v' }, '<leader>of', '<cmd>Obsidian quick_switch<CR>', { desc = '[f]ind note' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ol', '<cmd>Obsidian links<CR>', { desc = 'show [l]ink' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ob', '<cmd>Obsidian backlinks<CR>', { desc = '[b]acklinks' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ot', '<cmd>Obsidian tags<CR>', { desc = '[t]ags picker' })
      vim.keymap.set({ 'n', 'v' }, '<leader>od', '<cmd>Obsidian today<CR>', { desc = "open to[d]ay's rote" })
      vim.keymap.set({ 'n', 'v' }, '<leader>oy', '<cmd>Obsidian yesterday<CR>', { desc = "open [y]esterday's rote" })
      vim.keymap.set({ 'n', 'v' }, '<leader>om', '<cmd>Obsidian tomorrow<CR>', { desc = "open to[m]orrow's rote" })
      vim.keymap.set({ 'n', 'v' }, '<leader>oD', '<cmd>Obsidian dailies<CR>', { desc = 'open [D]ailies picker' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ov', '<cmd>Obsidian toc<CR>', { desc = 'open TOC [v]iew' })
      vim.keymap.set({ 'n', 'v' }, '<leader>oi', function()
        snack_input_and_execute('Enter image name:', 'Obsidian paste_img')
      end, { desc = 'paste [i]mage' })
      vim.keymap.set({ 'n', 'v' }, '<leader>or', function()
        snack_input_and_execute('Enter new name or --dry-run:', 'Obsidian rename')
      end, { desc = '[r]ename note' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ow', function()
        snack_input_and_execute('Enter workspace name:', 'Obsidian workspace')
      end, { desc = 'switch [w]orkspace' })
      vim.keymap.set({ 'v' }, '<leader>oe', function()
        snack_input_and_execute('Enter title for extracted note:', 'Obsidian extract_note')
      end, { desc = '[e]xtract note' })

      local vault_root = vim.fs.normalize '~/Documents/Obsidian'
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('obsidian_vault', { clear = true }),
        pattern = 'markdown',
        callback = function(args)
          local name = vim.api.nvim_buf_get_name(args.buf)
          if name ~= '' and name:find('^' .. vim.pesc(vault_root) .. '/') then
            -- Show markdown markers (**, *, `, ==, [[) as-is; bold/italic/code
            -- styling still applies via treesitter and obsidian UI highlights.
            vim.opt_local.conceallevel = 0
          end
        end,
      })
    end,
  },
}
