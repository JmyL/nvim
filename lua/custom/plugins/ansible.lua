return {
  {
    'pearofducks/ansible-vim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      -- Full path is matched as \v/<pattern>. Sets ft=<lang>.jinja2.
      vim.g.ansible_template_syntaxes = {
        [ [[.*\.pbtxt\.j2]] ] = 'pbtxt',
        [ [[.*\.pbtx\.j2]] ] = 'pbtxt',
      }
    end,
    config = function()
      require('ansible').setup()
      -- ansible-vim sets *.j2 to jinja2; reuse the jinja treesitter parser.
      vim.treesitter.language.register('jinja', 'jinja2')

      -- *.pbtxt.j2 / *.pbtx.j2 → pbtxt.jinja2: jinja outer + textproto host.
      local jinja_paths = vim.api.nvim_get_runtime_file('parser/jinja.*', false)
      if jinja_paths[1] then
        vim.treesitter.language.add('pbtxt_jinja', {
          path = jinja_paths[1],
          symbol_name = 'jinja',
        })
        vim.treesitter.language.register('pbtxt_jinja', 'pbtxt.jinja2')

        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'pbtxt.jinja2',
          callback = function(args)
            if vim._ts_has_language 'pbtxt_jinja' then
              vim.bo[args.buf].syntax = ''
              vim.treesitter.start(args.buf, 'pbtxt_jinja')
            end
          end,
        })
      else
        vim.notify('ansible: jinja parser missing; *.pbtxt.j2 will not get textproto injection', vim.log.levels.WARN)
      end
    end,
  },
}
