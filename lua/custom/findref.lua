local M = {}

-- Parse a `file[:line]` token like "ingestion_report.proto:23" or "src/main.rs:120-130".
-- Returns file name and a line number (nil when absent, start line for ranges).
M.parse = function(token)
  if not token or token == '' then
    return nil, nil
  end
  -- "file:23-45" jumps to the start of the range
  local file, first = token:match '^(.-):(%d+)-%d+$'
  if file and file ~= '' then
    return file, tonumber(first)
  end
  local name, line = token:match '^(.-):(%d+)$'
  if name and name ~= '' then
    return name, tonumber(line)
  end
  return token, nil
end

-- Token under the cursor, stripped of markdown decorations (backticks, parens, commas).
local function token_under_cursor()
  local word = vim.fn.expand '<cWORD>'
  if not word or word == '' then
    return nil
  end
  return word:match '[%w%._%-/:]+'
end

local function git_root(dir)
  local root = vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })[1]
  if vim.v.shell_error == 0 and root and root ~= '' then
    return root
  end
  return nil
end

local function search_roots()
  local roots = {}
  local seen = {}
  local function add(root)
    if root and root ~= '' and not seen[root] then
      seen[root] = true
      table.insert(roots, root)
    end
  end

  add(vim.uv.cwd())
  local bufdir = vim.fn.expand '%:p:h'
  if bufdir ~= '' then
    add(git_root(bufdir))
  end
  add(git_root(vim.uv.cwd() or '.'))

  return roots
end

M.search = function(name)
  local results = {}
  local seen = {}
  for _, root in ipairs(search_roots()) do
    local out = vim.fn.systemlist {
      'rg',
      '--files',
      '--hidden',
      '--glob',
      '!.git/',
      '--glob',
      name,
      root,
    }
    -- rg exits with 1 when there are no matches, 2 on real errors
    if vim.v.shell_error <= 1 then
      for _, path in ipairs(out) do
        if path ~= '' and not seen[path] then
          seen[path] = true
          table.insert(results, path)
        end
      end
    end
  end
  return results
end

local function open_at(path, line)
  vim.cmd.edit(vim.fn.fnameescape(path))
  if line and line > 0 then
    pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    vim.cmd 'normal! zz'
  end
end

local function pick(matches, name, line)
  local actions = require 'telescope.actions'
  local actions_state = require 'telescope.actions.state'
  local conf = require('telescope.config').values
  local finders = require 'telescope.finders'
  local make_entry = require 'telescope.make_entry'
  local pickers = require 'telescope.pickers'

  local opts = {
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local entry = actions_state.get_selected_entry()
        if entry then
          local path = entry.path or entry.value
          actions.close(prompt_bufnr)
          if path then
            open_at(path, line)
          end
        end
      end)
      return true
    end,
  }

  local title = 'Jump: ' .. name
  if line then
    title = title .. ':' .. line
  end

  pickers
    .new(opts, {
      prompt_title = title,
      finder = finders.new_table {
        results = matches,
        entry_maker = make_entry.gen_from_file(opts),
      },
      sorter = conf.generic_sorter(opts),
      previewer = conf.file_previewer(opts),
    })
    :find()
end

M.open_file_line = function()
  local token = token_under_cursor()
  if not token then
    vim.notify('No file reference under cursor', vim.log.levels.WARN)
    return
  end

  local name, line = M.parse(token)
  if not name or name == '' then
    vim.notify('No file reference under cursor', vim.log.levels.WARN)
    return
  end

  local matches = M.search(name)
  if #matches == 0 then
    vim.notify(('No file matching %s in cwd or git root'):format(name), vim.log.levels.WARN)
    return
  end
  if #matches == 1 then
    open_at(matches[1], line)
    return
  end
  pick(matches, name, line)
end

return M
