# Agent instructions for this Neovim config

This repository (`~/.config/nvim`, `JmyL/nvim`) is the Neovim config. It is its own git repo, not managed through chezmoi.

## Test, then manage

After any change, **always verify before committing**. Do not ask the user whether to manage when tests pass.

1. **Test** the change with the checks that fit the edit (see below).
2. **On success** — run the manage workflow automatically (commit + push). Do not wait for `관리해 줘`.
3. **On failure** — stop. Report what failed and discuss the next step with the user. Do not commit or push.

Skip auto-manage only when the user asks not to commit/push, asks to inspect/test only, or the change is intentionally incomplete/local-only.

### What to test

Pick the smallest set that covers the change:

- **Lua edits:** `stylua --check` on touched Lua files (matches CI in `.github/workflows/stylua.yml`).
- **Config / plugin load:** headless Neovim smoke that the edit would break if wrong (e.g. `nvim --headless -u …` / `:qa`, or loading the changed module). Prefer failing loudly over a silent no-op.
- **lazy.nvim `build` hooks:** run `:Lazy build <plugin>` (headless if practical) and confirm it exits without shell/Lua errors.
- **Plugin updates:** after `:Lazy sync` / lock changes, smoke that Neovim still starts; keep `lazy-lock.json` with related config in the same commit.

If no automated check exists for a change, say so and use the closest smoke you can; do not pretend a test passed.

## Manage workflow

Triggered automatically after successful tests, or when the user explicitly asks to **manage** (`관리해 줘`, `관리해`, or equivalent):

1. Fetch and rebase onto the tracked remote branch if behind (or if the user notes unpulled commits).
2. Commit the relevant changes. If they ask to split (`각각`, `나눠서`), make separate commits per logical change.
3. **Push immediately** after a successful commit — do not wait to be asked again for push.

Prefer infrequent, intentional plugin updates over habitual `:Lazy sync`.

- After updating plugins, commit `lazy-lock.json` together with any related config changes in the same commit, so a working pair of lock + config can be restored together.
- If an update breaks Neovim, restore the previous lock (and config) rather than debugging against a mixed state.
