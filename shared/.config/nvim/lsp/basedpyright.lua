return {
  settings = {
    basedpyright = {
      -- Let ruff (conform: ruff_organize_imports) handle imports
      disableOrganizeImports = true,
      analysis = {
        -- basedpyright's own default ruleset: all rules on as warning/error
        typeCheckingMode = 'recommended',
        -- Auto-insert `f` when typing `{` inside a string (basedpyright feature)
        autoFormatStrings = true,
        -- Use typing_extensions for older Python targets
        useTypingExtensions = true,
        -- Pylance-style inlay hints (basedpyright feature)
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = true,
        },
      },
    },
  },
}
