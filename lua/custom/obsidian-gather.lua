-- Gather open issue/plan checkboxes from the most recent previous daily note
-- into today's daily note. Walks backwards day by day from yesterday; the
-- first daily file that has any `- [ ]` under `## Issues` or `## Plans` is the
-- source. Already-listed ids and `done-plan` notes are skipped.
local M = {}

local function daily_path(vault, date)
  return vault .. '/' .. date .. '.md'
end

local function prev_date(date)
  local y, m, d = date:match '^(%d%d%d%d)-(%d%d)-(%d%d)$'
  if not y then
    return nil
  end
  return os.date('%Y-%m-%d', os.time { year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 } - 86400)
end

local function section_of(line)
  return line:match '^##%s+(Issues)%s*$' or line:match '^##%s+(Plans)%s*$'
end

local function open_items(lines)
  local items = {}
  local section
  for _, line in ipairs(lines) do
    local s = section_of(line)
    if s then
      section = s
    elseif line:match '^#' then
      section = nil
    elseif section then
      local text = line:match '^%- %[[ ]%](.+)$'
      if text then
        items[#items + 1] = {
          section = section,
          text = text:gsub('^%s+', ''):gsub('%s+$', ''),
          id = text:match '^%s*%[%[([^|%]]-)|' or text:match '^%s*%[%[([^|%]]-)%]%]',
        }
      end
    end
  end
  return items
end

local function frontmatter_tags(path)
  local f = io.open(path, 'r')
  if not f then
    return {}
  end
  local tags = {}
  local in_fm, in_tags = false, false
  for line in f:lines() do
    if line == '---' then
      if in_fm then
        break
      end
      in_fm = true
    elseif in_fm then
      local inline = line:match '^tags:%s*%[(.*)%]%s*$'
      if line:match '^tags:' then
        in_tags = true
        if inline then
          for tag in inline:gmatch '[^,%s]+' do
            tags[tag] = true
          end
        end
      elseif in_tags and line:match '^%s+-%s+' then
        tags[line:match '^%s+-%s+(%S+)'] = true
      else
        in_tags = false
      end
    end
  end
  f:close()
  return tags
end

local function is_done_plan(vault, id)
  if not id then
    return false
  end
  local path = vault .. '/' .. id .. '.md'
  if vim.uv.fs_stat(path) == nil then
    return false
  end
  return frontmatter_tags(path)['done-plan'] == true
end

local function find_heading(lines, name)
  for i, line in ipairs(lines) do
    if line:match('^##%s+' .. name .. '%s*$') then
      return i
    end
  end
end

local function insert_section(lines, name, texts)
  local h = find_heading(lines, name)
  if h then
    for i = #texts, 1, -1 do
      table.insert(lines, h + 1, '- [ ] ' .. texts[i])
    end
  else
    while lines[#lines] == '' do
      table.remove(lines)
    end
    if #lines > 0 and lines[#lines] ~= '' then
      lines[#lines + 1] = ''
    end
    lines[#lines + 1] = '## ' .. name
    for _, t in ipairs(texts) do
      lines[#lines + 1] = '- [ ] ' .. t
    end
  end
end

function M.gather(opts)
  opts = opts or {}
  local vault = opts.vault or vim.fn.expand '~/Documents/Obsidian'
  local today = opts.today or os.date '%Y-%m-%d'
  local max_days = opts.max_days or 365

  local date = today
  local source
  for _ = 1, max_days do
    date = prev_date(date)
    if not date then
      break
    end
    local path = daily_path(vault, date)
    if vim.uv.fs_stat(path) then
      local items = open_items(vim.fn.readfile(path))
      if #items > 0 then
        source = { date = date, items = items }
        break
      end
    end
  end

  if not source then
    vim.notify('obsidian-gather: no daily with open issue/plan found', vim.log.levels.INFO)
    return
  end

  local today_path = daily_path(vault, today)
  if vim.uv.fs_stat(today_path) == nil then
    local ok = pcall(vim.cmd, 'Obsidian today')
    if not ok or vim.uv.fs_stat(today_path) == nil then
      vim.notify('obsidian-gather: could not create today daily', vim.log.levels.ERROR)
      return
    end
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(today_path))
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local existing = {}
  for _, line in ipairs(lines) do
    for id in line:gmatch '%[%[([^|%]]*)|' do
      existing[id] = true
    end
  end

  local by_section = { Issues = {}, Plans = {} }
  local n_dup, n_done = 0, 0
  for _, item in ipairs(source.items) do
    if item.id and existing[item.id] then
      n_dup = n_dup + 1
    elseif is_done_plan(vault, item.id) then
      n_done = n_done + 1
    else
      local texts = by_section[item.section]
      texts[#texts + 1] = item.text
      if item.id then
        existing[item.id] = true
      end
    end
  end

  local n_added = 0
  for _, name in ipairs { 'Issues', 'Plans' } do
    if #by_section[name] > 0 then
      insert_section(lines, name, by_section[name])
      n_added = n_added + #by_section[name]
    end
  end

  if n_added == 0 then
    vim.notify(
      ('obsidian-gather: %s had %d open item(s), all already in today (%d done-plan skipped)'):format(source.date, #source.items, n_done),
      vim.log.levels.INFO
    )
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd 'silent write'
  vim.notify(
    ('obsidian-gather: added %d item(s) from %s (%d already in today, %d done-plan skipped)'):format(n_added, source.date, n_dup, n_done),
    vim.log.levels.INFO
  )
end

return M
