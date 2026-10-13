-- Gather open issue/plan checkboxes and the whole Todos section from the most
-- recent previous daily note into today's daily note. Walks backwards day by
-- day from yesterday; the first daily file that has any open `- [ ]` under
-- `## Issues` / `## Plans`, or any `## Todos` content, is the source.
-- Already-listed ids/texts and `done-plan` notes are skipped.
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

-- A heading that starts a new section: `# Title` / `## Title` with text.
-- Bare `##` or `### Sub` lines do not end a section.
local function is_heading(line)
  return line:match '^##?%s+%S' ~= nil
end

local function section_of(line)
  return line:match '^##%s+(Issues)%s*$' or line:match '^##%s+(Plans)%s*$' or line:match '^##%s+(Todos)%s*$'
end

-- Open `- [ ]` lines under Issues/Plans only. Todos is handled by full copy.
local function open_items(lines)
  local items = {}
  local section
  for _, line in ipairs(lines) do
    local s = section_of(line)
    if s then
      section = s
    elseif is_heading(line) then
      section = nil
    elseif section and section ~= 'Todos' then
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

-- Body of a section with edge blank lines trimmed, or nil if absent/empty.
local function section_body(lines, name)
  local h = find_heading(lines, name)
  if not h then
    return nil
  end
  local body = {}
  for i = h + 1, #lines do
    if is_heading(lines[i]) then
      break
    end
    body[#body + 1] = lines[i]
  end
  while #body > 0 and body[1] == '' do
    table.remove(body, 1)
  end
  while #body > 0 and body[#body] == '' do
    table.remove(body)
  end
  if #body == 0 then
    return nil
  end
  return body
end

-- Index just after the last non-blank line of a section (before trailing
-- blanks, the next heading, or EOF).
local function section_end(lines, name)
  local h = find_heading(lines, name)
  if not h then
    return nil
  end
  local e = h
  for i = h + 1, #lines do
    if is_heading(lines[i]) then
      break
    end
    if lines[i]:match '%S' then
      e = i
    end
  end
  return e
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

-- Copy source Todos body into today's Todos, skipping lines already present
-- (by trimmed text), lines whose linked note id is already in today, and lines
-- linked to a `done-plan` note. Creates the section when missing.
local function append_todos(lines, body, seen_text, existing, vault, counts)
  local h = find_heading(lines, 'Todos')
  local inserted = {}
  for _, line in ipairs(body) do
    if line:match '^%s*$' then
      if not h then
        inserted[#inserted + 1] = line
      end
    else
      local t = line:gsub('^%s+', ''):gsub('%s+$', '')
      local id = t:match '%[%[([^|%]]-)|'
      if seen_text[t] then
        counts.n_dup = counts.n_dup + 1
      elseif id and existing[id] then
        counts.n_dup = counts.n_dup + 1
      elseif id and is_done_plan(vault, id) then
        counts.n_done = counts.n_done + 1
      else
        inserted[#inserted + 1] = line
        if id then
          existing[id] = true
        end
      end
    end
  end
  if #inserted == 0 then
    return 0
  end
  local e = section_end(lines, 'Todos')
  if e then
    for i = #inserted, 1, -1 do
      table.insert(lines, e + 1, inserted[i])
    end
  else
    while lines[#lines] == '' do
      table.remove(lines)
    end
    if #lines > 0 and lines[#lines] ~= '' then
      lines[#lines + 1] = ''
    end
    lines[#lines + 1] = '## Todos'
    for _, l in ipairs(inserted) do
      lines[#lines + 1] = l
    end
  end
  return #inserted
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
      local lines = vim.fn.readfile(path)
      local items = open_items(lines)
      local todos = section_body(lines, 'Todos')
      if #items > 0 or todos then
        source = { date = date, items = items, todos = todos }
        break
      end
    end
  end

  if not source then
    vim.notify('obsidian-gather: no daily with open issue/plan/todo found', vim.log.levels.INFO)
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
  local seen_text = {}
  for _, line in ipairs(lines) do
    for id in line:gmatch '%[%[([^|%]]*)|' do
      existing[id] = true
    end
    local t = line:gsub('^%s+', ''):gsub('%s+$', '')
    if t ~= '' then
      seen_text[t] = true
      local content = t:match '^%- %[[ x]%]%s*(.+)$' or t:match '^%-%s+(.+)$'
      if content then
        seen_text[content] = true
      end
    end
  end

  local counts = { n_dup = 0, n_done = 0 }
  local by_section = { Issues = {}, Plans = {} }
  for _, item in ipairs(source.items) do
    if (item.id and existing[item.id]) or seen_text[item.text] then
      counts.n_dup = counts.n_dup + 1
    elseif is_done_plan(vault, item.id) then
      counts.n_done = counts.n_done + 1
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
  if source.todos then
    n_added = n_added + append_todos(lines, source.todos, seen_text, existing, vault, counts)
  end

  if n_added == 0 then
    vim.notify(
      ('obsidian-gather: %s had %d open item(s), all already in today (%d done-plan skipped)'):format(source.date, #source.items, counts.n_done),
      vim.log.levels.INFO
    )
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd 'silent write'
  vim.notify(
    ('obsidian-gather: added %d item(s) from %s (%d already in today, %d done-plan skipped)'):format(n_added, source.date, counts.n_dup, counts.n_done),
    vim.log.levels.INFO
  )
end

return M
