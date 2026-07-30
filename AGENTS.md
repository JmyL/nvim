# Agent instructions for this Neovim config

This repository (`~/.config/nvim`, `JmyL/nvim`) is the Neovim config. It is its own git repo, not managed through chezmoi.

## Git workflow

When the user asks to **manage** changes (`관리해 줘`, `관리해`, or equivalent), treat that as the full default workflow:

1. Fetch and rebase onto the tracked remote branch if behind (or if the user notes unpulled commits).
2. Commit the relevant changes. If they ask to split (`각각`, `나눠서`), make separate commits per logical change.
3. **Push immediately** after a successful commit — do not wait to be asked again for push.

Skip the commit and/or push only when the user asks not to, asks to inspect/test only, or the change is intentionally incomplete/local-only.

Prefer infrequent, intentional plugin updates over habitual `:Lazy sync`.

- After updating plugins, commit `lazy-lock.json` together with any related config changes in the same commit, so a working pair of lock + config can be restored together.
- If an update breaks Neovim, restore the previous lock (and config) rather than debugging against a mixed state.
