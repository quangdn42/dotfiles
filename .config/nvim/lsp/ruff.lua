return {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
  cmd_env = { RUFF_TRACE = 'messages' },
  init_options = {
    settings = {
      logLevel = 'error',
    },
  },
}
