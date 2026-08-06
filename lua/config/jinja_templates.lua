-- Dual highlighting for Jinja templates: *.<host>.j2
-- Outer language is Jinja; host language is inferred from the pre-.j2 extension
-- (e.g. trace.pbtxt.j2 → textproto, foo.yaml.j2 → yaml). Plain *.j2 stays Jinja-only.

local M = {}

local jinja_parser_path ---@type string|nil
local ensured = false

local function jinja_parser()
  if jinja_parser_path then
    return jinja_parser_path
  end
  jinja_parser_path = vim.api.nvim_get_runtime_file('parser/jinja.*', false)[1]
  return jinja_parser_path
end

---Resolve treesitter host language from a `name.<ext>.j2` path.
---@param path string
---@return string|nil
local function host_language(path)
  local base = vim.fs.basename(path):match '^(.*)%.[jJ]2$'
  if not base or not base:find '%.' then
    return nil
  end

  local ft = vim.filetype.match { filename = base }
  if not ft then
    local ext = base:match '%.([^%.]+)$'
    if ext then
      ft = vim.filetype.match { filename = 'file.' .. ext }
    end
  end
  if not ft then
    return nil
  end

  local lang = vim.treesitter.language.get_lang(ft) or ft
  if not vim._ts_has_language(lang) and not vim.treesitter.language.add(lang) then
    return nil
  end
  return lang
end

local function ensure_dynamic_lang()
  if ensured then
    return true
  end
  local path = jinja_parser()
  if not path then
    return false
  end

  vim.treesitter.language.add('jinja_dyn', {
    path = path,
    symbol_name = 'jinja',
  })

  vim.treesitter.query.add_directive('inject-j2-host!', function(_, _, bufnr, _, metadata)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == '' then
      return
    end
    local lang = host_language(name)
    if lang then
      metadata['injection.language'] = lang
    end
  end, { force = true })

  -- Keep jinja_inline / comment injections; add filename-based host for content.
  vim.treesitter.query.set(
    'jinja_dyn',
    'injections',
    [[
((inline) @injection.content
  (#set! injection.language "jinja_inline"))

((comment) @injection.content
  (#set! injection.language "comment"))

((content) @injection.content
  (#inject-j2-host!)
  (#set! injection.combined))
]]
  )
  vim.treesitter.query.set('jinja_dyn', 'highlights', '; inherits: jinja\n')
  vim.treesitter.query.set('jinja_dyn', 'folds', '; inherits: jinja\n')
  vim.treesitter.query.set('jinja_dyn', 'indents', '; inherits: jinja\n')

  ensured = true
  return true
end

---@param buf integer
local function attach(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if not host_language(name) then
    return
  end
  if not ensure_dynamic_lang() then
    return
  end
  pcall(vim.treesitter.stop, buf)
  vim.bo[buf].syntax = ''
  vim.treesitter.start(buf, 'jinja_dyn')
end

function M.setup()
  vim.treesitter.language.register('jinja', 'jinja2')

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('jinja-templates-dual', { clear = true }),
    pattern = { 'jinja', 'jinja2' },
    callback = function(args)
      -- After kickstart treesitter attach for plain jinja.
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          attach(args.buf)
        end
      end)
    end,
  })
end

return M
