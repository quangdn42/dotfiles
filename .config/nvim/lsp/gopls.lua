return {
  on_attach = function()
    -- enable inlay hints
    vim.lsp.inlay_hint.enable()
  end,
  settings = {
    gopls = {
      -- Build
      directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
      -- Formatting
      gofumpt = true,
      -- UI
      codelenses = {
        vulncheck = true,
        test = true,
      },
      semanticTokens = true,
      -- semanticTokensTypes = { string = false, number = false }, -- this doesn't work yet for some reason
      -- so use the noSemantic version instead
      noSemanticString = true,
      noSemanticNumber = true,
      -- Inlay hints
      hints = {
        -- assignVariableTypes = true,
        -- compositeLiteralFields = true,
        -- compositeLiteralTypes = true,
        constantValues = true,
        -- functionTypeParameters = true,
        -- parameterNames = true,
        rangeVariableTypes = true,
      },
      -- Diagnostics
      staticcheck = true,
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      -- Completion
      usePlaceholders = false,
    },
  },
}
