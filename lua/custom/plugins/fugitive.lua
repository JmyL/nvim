-- :Git follows the current file's repo. Keep the directory Neovim was
-- started in so <leader>gs can still open that clone after editing a
-- file outside it (oil/:cd must not steal this).
local launch_cwd = vim.fn.getcwd()

-- Last cursor line per status buffer, keyed by bufname. Fugitive forces the
-- cursor to line 1 when revisiting a status buffer that is already displayed
-- (s:StatusCommand runs a bare `1`) and a re-created one starts at line 1
-- after bufhidden=delete wiped it, so remember where we left off and put the
-- cursor back once fugitive is done moving it around.
local git_status_cursors = {}

local function is_status_buffer(buf)
  return vim.bo[buf].filetype == 'fugitive' and vim.api.nvim_buf_get_name(buf):match '^fugitive://.*//$' ~= nil
end

local function save_status_cursor()
  local buf = vim.api.nvim_get_current_buf()
  if is_status_buffer(buf) then
    git_status_cursors[vim.api.nvim_buf_get_name(buf)] = vim.fn.line '.'
  end
end

local function restore_status_cursor()
  -- Everything fugitive does to the cursor happens synchronously inside the
  -- :Git command below; scheduling lands the restore after all of it.
  vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    local line = git_status_cursors[vim.api.nvim_buf_get_name(buf)]
    if not is_status_buffer(buf) or not line or line > vim.api.nvim_buf_line_count(buf) then
      return
    end
    vim.cmd('normal! ' .. line .. 'G')
  end)
end

local function git_status_open(git_dir)
  save_status_cursor()
  vim.cmd(vim.fn['fugitive#Command'](0, 0, 0, 0, '', '++curwin', git_dir))
  restore_status_cursor()
end

local function git_in(dir, arg)
  local git_dir = vim.fn.FugitiveExtractGitDir(dir)
  if git_dir == '' then
    vim.notify('No git repository in ' .. dir, vim.log.levels.WARN)
    return
  end
  vim.cmd(vim.fn['fugitive#Command'](0, 0, 0, 0, '', arg, git_dir))
end

local function git_status(dir)
  local git_dir = vim.fn.FugitiveExtractGitDir(dir)
  if git_dir == '' then
    vim.notify('No git repository in ' .. dir, vim.log.levels.WARN)
    return
  end
  git_status_open(git_dir)
end

local function git_log_oneline(dir)
  git_in(dir, '++curwin log --oneline')
end

return {
  {
    'tpope/vim-fugitive',
    lazy = false,
    keys = {
      {
        '<leader>gs',
        function()
          git_status(launch_cwd)
        end,
        desc = '[G]it [s]tatus',
      },
      {
        '<leader>gS',
        function()
          -- :0Git semantics: the repo of the current buffer's file.
          local git_dir = vim.fn.exists '*FugitiveGitDir' == 1 and vim.fn.FugitiveGitDir() or ''
          if git_dir == '' then
            git_dir = vim.fn.FugitiveExtractGitDir(vim.api.nvim_buf_get_name(0))
          end
          if git_dir == '' then
            vim.notify('No git repository for the current buffer', vim.log.levels.WARN)
            return
          end
          git_status_open(git_dir)
        end,
        desc = '[G]it [S]tatus (file repo)',
      },
      {
        '<leader>gl',
        function()
          git_log_oneline(launch_cwd)
        end,
        desc = '[G]it [l]og --oneline',
      },
      { '<leader>gb', ':Git blame --date=short --abbrev=6<CR>', desc = '[G]it [b]lame' },
    },
    silent = true,
    config = function()
      -- Fixed-width author so :Gclog subjects stay aligned.
      vim.g.fugitive_summary_format = '%<(20,trunc)%an %s'

      local group = vim.api.nvim_create_augroup('fugitive_cursor_restore', { clear = true })

      -- Fugitive's <CR> is Gedit, which calls BlurStatus: leave the status
      -- window, or :new a split if there is no other usable window. The
      -- ++curwin status already occupies the current window; open the file
      -- there instead.
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'fugitive',
        callback = function()
          vim.keymap.set('n', '<CR>', function()
            pcall(vim.api.nvim_win_del_var, 0, 'fugitive_status')
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>fugitive:<CR>', true, false, true), 'm', false)
          end, { buffer = true, silent = true, desc = 'Open file in current window' })
        end,
      })

      vim.api.nvim_create_autocmd('BufLeave', {
        group = group,
        pattern = 'fugitive://*.git//',
        callback = function()
          local bufname = vim.fn.bufname()
          git_status_cursors[bufname] = vim.fn.line '.'
        end,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        pattern = 'fugitive://*.git//',
        callback = function()
          local bufname = vim.fn.bufname()
          if git_status_cursors[bufname] then
            vim.cmd('normal! ' .. git_status_cursors[bufname] .. 'G')
          end
        end,
      })

      -- :Git blame scrollbinds to one origin window, but never refreshes
      -- when that window opens a different buffer. Re-blame the new buffer;
      -- if it cannot be blamed (help, status, non-git, ...), close the
      -- blame window instead of leaving stale output behind. The re-blame
      -- runs on the next loop tick: from inside BufEnter, fugitive's
      -- filetype detection is suppressed by autocmd nesting rules and the
      -- new blame buffer would be left unhighlighted.
      --
      -- The state is swept per loop tick instead of tracked per window:
      -- each :Git blame creates a fresh temp buffer whose origin_winid
      -- points at the same origin window, so stale splits would
      -- accumulate if they were not collected together.
      local blame_busy = false

      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('fugitive_blame_follow', { clear = true }),
        callback = function()
          if blame_busy then
            return
          end
          -- Collect stale blame windows first so all of them get cleaned
          -- up in one pass, whatever their individual origins.
          local stale = {}
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'fugitiveblame' then
              local ok, state = pcall(vim.fn['fugitive#Result'], buf)
              if
                ok
                and state.filetype == 'fugitiveblame'
                and state.origin_winid
                and state.origin_bufnr
                and state.origin_bufnr > 0
                and vim.api.nvim_win_is_valid(state.origin_winid)
                and vim.api.nvim_win_get_buf(state.origin_winid) ~= state.origin_bufnr
              then
                stale[#stale + 1] = { win = win, state = state }
              end
            end
          end
          if #stale == 0 then
            return
          end

          blame_busy = true
          vim.schedule(function()
            for _, item in ipairs(stale) do
              local state = item.state
              if not vim.api.nvim_win_is_valid(state.origin_winid) or vim.api.nvim_win_get_buf(state.origin_winid) == state.origin_bufnr then
                goto continue
              end
              local origin_buf = vim.api.nvim_win_get_buf(state.origin_winid)
              local blamable = vim.bo[origin_buf].buftype == ''
                and vim.bo[origin_buf].buflisted
                and vim.fn.FugitiveExtractGitDir(vim.api.nvim_buf_get_name(origin_buf)) ~= ''
              if blamable then
                -- Unbind the origin window first: fugitive's own
                -- re-blame sweep only deletes the scrollbound blame
                -- matching the new origin, leaving older blame
                -- windows to pile up. Without scrollbind it deletes
                -- every blame window before splitting a fresh one.
                pcall(vim.api.nvim_win_set_option, state.origin_winid, 'scrollbind', false)
                local updated = pcall(vim.api.nvim_win_call, state.origin_winid, function()
                  vim.cmd 'Git blame --date=short --abbrev=6'
                end)
                if not updated then
                  pcall(vim.api.nvim_win_close, item.win, false)
                end
              else
                pcall(vim.api.nvim_win_close, item.win, false)
              end
              ::continue::
            end
            blame_busy = false
          end)
        end,
      })
    end,
  },
}
