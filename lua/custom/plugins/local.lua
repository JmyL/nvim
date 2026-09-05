return {
  {
    'klen/nvim-config-local',
    -- Must load at startup so project .nvim.lua is available for C++ LSP overrides.
    lazy = false,
    priority = 1000,
    config = function()
      local config_local = require 'config-local'
      config_local.setup {
        -- Default options (optional)

        -- Config file patterns to load (lua supported)
        config_files = { '.nvim.lua', '.nvimrc', '.exrc' },

        -- Where the plugin keeps files data
        hashfile = vim.fn.stdpath 'data' .. '/config-local',

        autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
        commands_create = true, -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalDeny)
        silent = false, -- Disable plugin messages (Config loaded/denied)
        lookup_parents = true, -- Lookup config files in parent directories
      }
    end,
  },
}
