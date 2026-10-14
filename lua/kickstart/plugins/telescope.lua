return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'catgoose/telescope-helpgrep.nvim' },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = '^1.0.0',
      },
      { 'gbprod/yanky.nvim' },
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      local builtin = require 'telescope.builtin'
      local previewers = require 'telescope.previewers'
      local lga_actions = require 'telescope-live-grep-args.actions'
      local hidden_grep_args = { '--hidden', '--glob', '!.git/' }
      local vimgrep_arguments = vim.deepcopy(require('telescope.config').values.vimgrep_arguments)
      vim.list_extend(vimgrep_arguments, hidden_grep_args)

      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          preview = {
            treesitter = false,
          },
          -- mappings = {
          --   i = { ['<c-enter>'] = 'to_fuzzy_refine' },
          -- },
        },
        -- pickers = {
        --   find_files = {
        --     theme = 'ivy',
        --   },
        -- },
        pickers = {
          live_grep = {
            additional_args = hidden_grep_args,
          },
          grep_string = {
            additional_args = hidden_grep_args,
          },
          buffers = {
            sort_mru = true, -- show recently used buffers first
            mappings = {
              i = {
                ['<C-x>'] = 'delete_buffer',
                ['<C-v>'] = false,
                ['<C-t>'] = false,
              },
              n = {
                ['<C-x>'] = 'delete_buffer',
                ['<C-v>'] = false,
                ['<C-t>'] = false,
              },
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
          },
          helpgrep = {
            ignore_paths = {
              vim.fn.stdpath 'state' .. '/lazy/readme',
            },
            default_grep = builtin.live_grep,
          },
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            vimgrep_arguments = vimgrep_arguments,
            -- define mappings, e.g.
            mappings = { -- extend mappings
              i = {
                ['<C-k>'] = lga_actions.quote_prompt(),
                ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
                -- freeze the current list and start a fuzzy search in the frozen list
                ['<C-space>'] = lga_actions.to_fuzzy_refine,
              },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
          },
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'yank_history')
      pcall(require('telescope').load_extension, 'helpgrep')
      pcall(require('telescope').load_extension, 'live_grep_args')

      -- Buffer previewer showing `git diff <base>...HEAD -- <file>` instead of
      -- the file contents. Used by <leader>sc so the preview matches the
      -- changed-file list (same `base...HEAD` range as custom.git-base).
      local function diff_previewer(base)
        return previewers.new_buffer_previewer {
          title = ('Diff vs %s'):format(base),
          define_preview = function(self, entry)
            vim.system({ 'git', 'diff', '--no-ext-diff', '--no-color', base .. '...HEAD', '--', entry.value }, { text = true }, function(res)
              vim.schedule(function()
                if not (self.state and vim.api.nvim_buf_is_valid(self.state.bufnr)) then
                  return
                end
                local out = vim.split(res.stdout or '', '\n', { trimempty = true })
                if #out == 0 then
                  out = { '(no diff vs ' .. base .. ')' }
                end
                vim.bo[self.state.bufnr].filetype = 'diff'
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, out)
              end)
            end)
          end,
        }
      end

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp Tag' })
      vim.keymap.set('n', '<leader>sH', '<cmd>Telescope helpgrep<CR>', { desc = '[s]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
      vim.keymap.set('n', '<leader>sj', builtin.jumplist, { desc = '[s]earch [j]umplist' })
      vim.keymap.set('n', '<leader>sF', function()
        builtin.find_files { hidden = true }
      end, { desc = '[s]earch [F]iles' })
      vim.keymap.set('n', '<leader>sf', builtin.git_files, { desc = '[s]earch [f]iles from git index' })
      vim.keymap.set('n', '<leader>sc', function()
        local base_branch = require('custom.git-base').detect()
        if not base_branch then
          vim.notify('Could not detect a base branch for current HEAD', vim.log.levels.WARN)
          return
        end

        builtin.find_files {
          prompt_title = ('Changed files vs %s'):format(base_branch),
          find_command = { 'git', 'diff', '--name-only', '--diff-filter=ACMRTUXB', base_branch .. '...HEAD' },
          previewer = diff_previewer(base_branch),
        }
      end, { desc = '[s]earch changed files vs [g]it base' })

      -- Previewer for <leader>sl: shows the diff matching each entry's git
      -- status. Staged entries diff index-vs-HEAD (`--cached`), unstaged diff
      -- worktree-vs-index, untracked files show their raw content.
      local function status_previewer()
        return previewers.new_buffer_previewer {
          title = 'Change preview',
          define_preview = function(self, entry)
            vim.schedule(function()
              if not (self.state and vim.api.nvim_buf_is_valid(self.state.bufnr)) then
                return
              end
              local out
              if entry.untracked then
                local res = vim.system({ 'cat', entry.value }, { text = true }):wait()
                if res.code == 0 then
                  out = vim.split(res.stdout or '', '\n', { trimempty = true })
                else
                  out = { '(could not read file)' }
                end
              else
                local cmds = {}
                if entry.staged then
                  cmds[#cmds + 1] = { 'git', 'diff', '--no-ext-diff', '--no-color', '--cached', '--', entry.value }
                end
                if entry.unstaged then
                  cmds[#cmds + 1] = { 'git', 'diff', '--no-ext-diff', '--no-color', '--', entry.value }
                end
                out = {}
                for _, cmd in ipairs(cmds) do
                  local res = vim.system(cmd, { text = true }):wait()
                  if res.code == 0 and (res.stdout or '') ~= '' then
                    vim.list_extend(out, vim.split(res.stdout, '\n', { trimempty = true }))
                  end
                end
                if #out == 0 then
                  out = { '(no diff)' }
                end
              end
              vim.bo[self.state.bufnr].filetype = 'diff'
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, out)
            end)
          end,
        }
      end

      -- List staged + unstaged + untracked files from `git status --porcelain`
      -- and preview each one with the matching diff (see status_previewer).
      vim.keymap.set('n', '<leader>sl', function()
        local res = vim.system({ 'git', 'status', '--porcelain', '-z', '--untracked-files=all' }, { text = true }):wait()
        if res.code ~= 0 then
          vim.notify('git status failed (not a git repo?)', vim.log.levels.WARN)
          return
        end

        local entries = {}
        local by_path = {}
        -- -z separates records with NUL; renames separate old/new with NUL too.
        local fields = vim.split(res.stdout, '\0', { plain = true })
        local i = 1
        while i <= #fields do
          local record = fields[i]
          i = i + 1
          if record ~= '' and #record >= 4 then
            local xy = record:sub(1, 2)
            local path = record:sub(4)
            if xy:match '^R' or xy:match '^.R' then
              -- With -z, rename records are `XY <new-path>\0<old-path>\0`:
              -- the record already holds the new path, the next field the old one.
              local old_path = fields[i]
              i = i + 1
              local new_path = path
              local function add_rename(staged, unstaged)
                local key = new_path .. '\0' .. tostring(staged) .. tostring(unstaged)
                if not by_path[key] then
                  by_path[key] = { value = new_path, path = new_path, staged = staged, unstaged = unstaged, rename = old_path }
                  table.insert(entries, by_path[key])
                end
              end
              local x, y = xy:sub(1, 1), xy:sub(2, 2)
              if x ~= ' ' and x ~= '?' then
                add_rename(true, false)
              end
              if y ~= ' ' and y ~= '?' then
                add_rename(false, true)
              end
            else
              local function add(staged, unstaged, untracked)
                local key = path .. '\0' .. tostring(staged) .. tostring(unstaged) .. tostring(untracked)
                if not by_path[key] then
                  by_path[key] = { value = path, path = path, staged = staged, unstaged = unstaged, untracked = untracked }
                  table.insert(entries, by_path[key])
                end
              end
              if xy == '??' then
                add(false, false, true)
              else
                local x, y = xy:sub(1, 1), xy:sub(2, 2)
                local is_staged = x ~= ' ' and x ~= '?'
                local is_unstaged = y ~= ' ' and y ~= '?'
                if is_staged or is_unstaged then
                  add(is_staged, is_unstaged, false)
                end
              end
            end
          end
        end

        if #entries == 0 then
          vim.notify('No staged/unstaged changes', vim.log.levels.INFO)
          return
        end

        local status_marks = {
          M = 'M',
          A = 'A',
          D = 'D',
          R = 'R',
          C = 'C',
          T = 'T',
          U = 'U',
        }
        local pickers = require 'telescope.pickers'
        local finders = require 'telescope.finders'
        local actions_state = require 'telescope.actions.state'
        local actions = require 'telescope.actions'
        local conf = require('telescope.config').values

        pickers
          .new({}, {
            prompt_title = 'Live & staged changes',
            finder = finders.new_table {
              results = entries,
              entry_maker = function(e)
                local marks = {}
                if e.untracked then
                  marks = { '??' }
                else
                  if e.staged then
                    marks[#marks + 1] = 'S'
                  end
                  if e.unstaged then
                    marks[#marks + 1] = 'W'
                  end
                end
                local display = table.concat(marks, '/') .. ' ' .. e.value
                if e.rename then
                  display = display .. (' (from %s)'):format(e.rename)
                end
                return {
                  value = e.value,
                  path = e.path,
                  ordinal = e.value,
                  display = display,
                  staged = e.staged,
                  unstaged = e.unstaged,
                  untracked = e.untracked,
                }
              end,
            },
            sorter = conf.generic_sorter {},
            previewer = status_previewer(),
            attach_mappings = function(_, map)
              map('i', '<CR>', function(prompt_bufnr)
                local selection = actions_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd.edit(vim.fn.fnameescape(selection.path))
              end)
              map('n', '<CR>', function(prompt_bufnr)
                local selection = actions_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd.edit(vim.fn.fnameescape(selection.path))
              end)
              return true
            end,
          })
          :find()
      end, { desc = '[s]earch [l]ive & staged changes (git status)' })
      vim.keymap.set('n', '<leader>so', builtin.builtin, { desc = '[s]earch with another [o]ption' })
      vim.keymap.set('n', '<leader>st', builtin.treesitter, { desc = '[s]earch using [t]reesitter query' })
      vim.keymap.set('n', '<leader>sd', builtin.grep_string, { desc = '[s]earch current wor[d]' })
      vim.keymap.set('n', '<leader>s/', function()
        require('telescope').extensions.live_grep_args.live_grep_args()
      end, { desc = '[s]earch [/] in all files' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[s]earch [r]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[s]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 0,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s;', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[s]earch [;] in open files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
