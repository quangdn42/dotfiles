return {
  before_init = function(_, config)
    config.settings.python = config.settings.python or {}
    config.settings.python.venvPath = config.root_dir
    config.settings.python.venv = '.venv'
  end,
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        -- ignore = { '*' },
      },
    },
  },
}
