-- Repeat any ]/[ motion (and f/F/t/T) with ; and ,
--
-- - ]c (gitsigns hunk) -> ; ; ;  -> ,  (jump back)
-- - ]o (obsidian link) -> ; ; ;  -> ,
-- - ]a (codecompanion section) -> ; ; ; -> ,
-- - f{char}/t{char} keep repeating with ;/,
--
-- stateful: ; repeats in the direction of the original jump, , inverts it
-- (Neovim's default behaviour for f/t).
return {
  {
    'mawkler/demicolon.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    opts = {
      keymaps = {
        repeat_motions = 'stateful',
        -- 'y': yanky [y/]y cycles yank history, not a jump
        disabled_keys = { 'p', 'I', 'A', 'f', 'i', 'y' },
      },
    },
  },
}
