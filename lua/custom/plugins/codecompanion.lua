return {
  {
    'olimorris/codecompanion.nvim',
    enabled = false,
    cmd = { 'CodeCompanionChat' },
    lazy = false,
    -- check https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    opts = {
      prompt_library = require 'config.codecompanion.prompt_library',
      display = {
        window = {
          layout = 'vertical',
        },
        action_palette = {
          width = 95,
          height = 10,
          prompt = 'Prompt ', -- Prompt used for interactive LLM calls
          provider = 'telescope', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
          opts = {
            show_preset_actions = true, -- Show the preset actions in the action palette?
            show_preset_prompts = true, -- Show the preset prompts in the action palette?
          },
        },
        chat = {
          auto_scroll = false,
        },
      },
      keymaps = {
        show_shortcuts = 'g?',
      },
      interactions = {
        -- background = {
        --   adapter = {
        --     name = 'codex',
        --   },
        -- },
        -- inline = {
        --   adapter = 'codex',
        -- },
        -- cmd = {
        --   adapter = 'codex',
        -- },
        chat = {
          adapter = {
            name = 'opencode',
          },
          slash_commands = {
            ['buffer'] = {
              keymaps = {
                modes = {
                  i = '<C-b>',
                  n = { '<C-b>' },
                },
              },
            },
            ['fetch'] = {
              keymaps = {
                modes = {
                  i = '<C-g>',
                  n = { '<C-g>' },
                },
              },
            },
            ['file'] = {
              keymaps = {
                modes = {
                  i = '<C-f>',
                  n = { '<C-f>' },
                },
              },
            },
            ['image'] = {
              keymaps = {
                modes = {
                  i = '<C-i>',
                  n = { '<C-i>' },
                },
              },
            },
            ['now'] = {
              keymaps = {
                modes = {
                  i = '<C-n>',
                  n = { '<C-n>' },
                },
              },
            },
            ['help'] = {
              keymaps = {
                modes = {
                  i = '<C-h>',
                  n = { '<C-h>' },
                },
              },
            },
            ['symbols'] = {
              keymaps = {
                modes = {
                  i = '<C-o>',
                  n = { '<C-o>' },
                },
              },
            },
            ['terminal'] = {
              keymaps = {
                modes = {
                  i = '<C-t>',
                  n = { '<C-t>' },
                },
              },
            },
            ['workspace'] = {
              keymaps = {
                modes = {
                  i = '<C-p>',
                  n = { '<C-p>' },
                },
              },
            },
            ['quickfix'] = {
              keymaps = {
                modes = {
                  i = '<C-q>',
                  n = { '<C-q>' },
                },
              },
            },
          },
          keymaps = {
            options = {
              modes = {
                n = 'g?',
              },
            },
            send = {
              modes = { n = '<C-s>', i = '<C-s>' },
              opts = {},
            },
            close = {
              modes = { n = '<C-c>', i = '<C-c>' },
              opts = {},
            },
            completion = {
              modes = { i = '<C-l>' },
              opts = {},
            },
          },
        },
      },
      adapters = {
        opencode = function()
          return require('codecompanion.adapters').extend('opencode', {
            env = {
              OPENAI_SYSTEM_PROMPT = "Never use Chinese characters (Hanja/漢字/한자)."
            },
          })
        end,
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = 'gh',
            save_chat_keymap = 'sc',
            auto_save = true,
            expiration_days = 0,
            picker = 'telescope', --- ("telescope", "snacks", "fzf-lua", or "default")
            auto_generate_title = false,
            title_generation_opts = {
              adapter = nil,
              model = nil,
              refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
              max_refreshes = 3,
            },
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
            enable_logging = false,
          },
        },
        -- mcphub = {
        --   callback = 'mcphub.extensions.codecompanion',
        --   opts = {
        --     make_vars = true,
        --     make_slash_commands = true,
        --     show_result_in_chat = true,
        --   },
        -- },
      },
      opts = {
        language = 'Korean',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- 'ravitemer/mcphub.nvim',
      'MeanderingProgrammer/render-markdown.nvim',
      'j-hui/fidget.nvim',
      'ravitemer/codecompanion-history.nvim',
      -- {
      --   'ravitemer/mcphub.nvim',
      --   build = 'npm install -g mcp-hub@latest',
      --   config = function()
      --     require('mcphub').setup()
      --   end,
      -- },
    },
    init = function()
      require('config.codecompanion.fidget-spinner'):init()
      vim.api.nvim_create_user_command('C', function(opts)
        local cmd = 'CodeCompanion'
        if opts.range > 0 then
          cmd = string.format("'<,'>%s", cmd)
        end
        if opts.args ~= '' then
          cmd = cmd .. ' ' .. opts.args
        end
        vim.cmd(cmd)
      end, { range = true, nargs = '*' })

      vim.api.nvim_create_user_command('CC', function(opts)
        local cmd = 'CodeCompanionChat'
        if opts.range > 0 then
          cmd = string.format("'<,'>%s", cmd)
        end
        if opts.args ~= '' then
          cmd = cmd .. ' ' .. opts.args
        end
        vim.cmd(cmd)
      end, { range = true, nargs = '*' })
      vim.keymap.set('n', '<leader>ao', ':CodeCompanionChat Toggle<CR>', { desc = '[a]i - t[o]ggle chat' })
      vim.keymap.set('n', '<leader>aO', ':CodeCompanionChat<CR>', { desc = '[a]i - [O]pen new chat' })
      vim.keymap.set('n', '<leader>ah', ':CodeCompanionHistory<CR>', { desc = '[a]i - [h]istory' })
      vim.keymap.set('v', '<leader>ad', ':CodeCompanionChat Add<CR>', { desc = '[a]i - ad[d] to chat' })
      vim.keymap.set({ 'n', 'v' }, '<leader>al', ':CodeCompanionActions<CR>', { desc = '[a]i - action [l]ist' })
      vim.keymap.set({ 'n', 'v' }, '<leader>aL', function()
        vim.api.nvim_feedkeys('V', 'n', false)
        vim.schedule(function()
          vim.cmd 'CodeCompanionActions'
        end)
      end, { desc = '[a]i - action [L]ist for a file' })
      vim.keymap.set('n', '<leader>ad', function()
        vim.api.nvim_feedkeys('V', 'n', false)
        vim.schedule(function()
          vim.cmd 'CodeCompanionChat Add'
        end)
      end, { desc = '[a]i - ad[d] to chat' })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'codecompanion',
        callback = function()
          vim.keymap.set('n', '[a', '?^## CodeCompanion<CR>', { buffer = true })
          vim.keymap.set('n', ']a', '/^## CodeCompanion<CR>', { buffer = true })
        end,
      })
      -- vim.g.codecompanion_auto_tool_mode = true
    end,
  },
}