-- Detect the base branch/commit a feature branch diverged from.
-- Shared by <leader>sc (telescope changed-file list), gitsigns <leader>gc
-- (diff-vs-base toggle) and fugitive <leader>gC (branch diff): each compares
-- against `<base>...HEAD` the same way.

local M = {}

-- Per-cwd cache keyed by cwd + HEAD sha: a branch switch or commit changes
-- HEAD and naturally invalidates the entry; a different repo gets its own.
local cache = {}

local function git_output(args, cwd)
  local cmd = { 'git' }
  if cwd and cwd ~= '' then
    cmd[#cmd + 1] = '-C'
    cmd[#cmd + 1] = cwd
  end
  vim.list_extend(cmd, args)
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  return vim.trim(res.stdout)
end

local function git_ref_exists(ref, cwd)
  return git_output({ 'rev-parse', '--verify', ref }, cwd) ~= nil
end

local function detect_created_from_branch(current, cwd)
  local reflog = git_output({ 'reflog', 'show', '--pretty=%gs', '--max-count=200', current }, cwd)
  if not reflog or reflog == '' then
    return nil
  end

  local lines = vim.split(reflog, '\n', { trimempty = true })
  -- Reflog is newest-first; scan oldest-first to find the branch origin.
  for i = #lines, 1, -1 do
    local source = lines[i]:match '^branch: Created from (.+)$'
    if source and source ~= '' and source ~= 'HEAD' then
      return source
    end
  end

  return nil
end

function M.detect(cwd)
  cwd = cwd or vim.fn.getcwd()

  local current = git_output({ 'branch', '--show-current' }, cwd)
  if not current or current == '' then
    return nil
  end

  local head_sha = git_output({ 'rev-parse', '--verify', 'HEAD' }, cwd)
  local entry = cache[cwd]
  if head_sha and entry and entry.head == head_sha then
    return entry.base
  end

  local candidates = {}
  local seen = {}
  local function normalize_ref(ref)
    if not ref or ref == '' then
      return nil
    end
    local short = ref:match '^refs/remotes/(.+)$' or ref:match '^refs/heads/(.+)$'
    return short or ref
  end

  local function add_candidate(ref)
    local norm = normalize_ref(ref)
    if norm and norm ~= '' and norm ~= current and norm ~= ('origin/' .. current) and not seen[norm] then
      seen[norm] = true
      table.insert(candidates, norm)
    end
  end

  -- Explicit per-branch override (same concept as gh's merge-base config).
  local gh_merge_base = git_output({ 'config', '--get', ('branch.%s.gh-merge-base'):format(current) }, cwd)
  if gh_merge_base and gh_merge_base ~= '' then
    add_candidate('origin/' .. gh_merge_base)
    add_candidate(gh_merge_base)
  end

  -- Try the branch origin if reflog captured it (e.g. "Created from development").
  local created_from = detect_created_from_branch(current, cwd)
  if created_from then
    add_candidate('origin/' .. created_from)
    add_candidate(created_from)
  end

  -- Typical integration branches (ree-drive usually targets development).
  local fallback_refs = {
    'origin/development',
    'development',
    vim.trim(git_output({ 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, cwd) or ''),
    'origin/main',
    'origin/master',
    'origin/develop',
    'main',
    'master',
    'develop',
    git_output({ 'rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{upstream}' }, cwd),
  }
  for _, ref in ipairs(fallback_refs) do
    add_candidate(ref)
  end

  local best_ref = nil
  local best_distance = math.huge
  local preference_rank = {}
  for i, ref in ipairs(candidates) do
    preference_rank[ref] = i
  end

  for _, ref in ipairs(candidates) do
    if git_ref_exists(ref, cwd) then
      local merge_base = git_output({ 'merge-base', '--fork-point', ref, 'HEAD' }, cwd) or git_output({ 'merge-base', 'HEAD', ref }, cwd)
      if merge_base and merge_base ~= '' then
        local distance = tonumber(git_output({ 'rev-list', '--count', merge_base .. '..HEAD' }, cwd))
        if distance then
          local is_better = distance < best_distance
          if distance == best_distance and best_ref then
            is_better = (preference_rank[ref] or math.huge) < (preference_rank[best_ref] or math.huge)
          end
          if is_better then
            best_ref = ref
            best_distance = distance
          end
        end
      end
    end
  end

  cache[cwd] = { head = head_sha, base = best_ref }
  return best_ref
end

return M
