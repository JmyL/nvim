return {
  ['Correct grammar'] = {
    interaction = 'inline',
    description = 'Correct the selected paragraph',
    opts = {
      -- index = 12,
      ignore_system_prompt = true,
      is_default = true,
      is_slash_cmd = false,
      modes = { 'v' },
      alias = 'correction',
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = 'system',
        content = [[ Please correct any errors in the following code/text, but keep the original structure, line breaks, and spacing as unchanged as possible.
  Only make changes necessary for correctness.
  ]],
        opts = {
          visible = false,
        },
      },

      {
        role = 'user',
        content = function(context)
          local code = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)

          return string.format(
            [[<user_prompt>
Please correct any errors in the following code/text from buffer %d.

```%s
%s
```

Keep the original structure, line breaks, and spacing as unchanged as possible.
Only make changes necessary for correctness.
</user_prompt>
]],
            context.bufnr,
            context.filetype,
            code
          )
        end,
        opts = {
          contains_code = true,
        },
      },
    },
  },
  ['Correct grammar (Chat)'] = {
    interaction = 'chat',
    description = 'Correct grammar in the current message',
    opts = {
      ignore_system_prompt = true,
      is_default = false,
      is_slash_cmd = true,
      alias = 'correction',
      auto_submit = false,
      user_prompt = [[Please paste the text you want corrected.]],
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = 'system',
        content = [[ Please correct grammar and wording while preserving the original meaning and formatting as much as possible.
Return only the corrected text.
]],
        opts = {
          visible = false,
        },
      },
      {
        role = 'user',
        content = [[Correct the following text:

#{user_prompt}
]],
      },
    },
  },
}
