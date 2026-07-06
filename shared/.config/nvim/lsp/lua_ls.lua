return {
  -- https://luals.github.io/wiki/settings/
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
      -- Ignore Lua_LS's noisy `missing-fields` warnings
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}
