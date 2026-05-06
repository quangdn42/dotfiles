return {
  dir = '~/workspaces/usage-tracker/',
  enabled = false, -- remember to run :UpdateRemotePlugins on enabling or disabling this
  config = function()
    local utracker = vim.api.nvim_create_augroup('UTracker', { clear = true })
    -- Pause the tracker when nvim loses focus, or when you enter Insert mode
    vim.api.nvim_create_autocmd({ 'VimEnter' }, {
      group = utracker,
      callback = function()
        vim.cmd 'UTrackerRun'
      end,
    })
    vim.api.nvim_create_autocmd({ 'VimLeave' }, {
      group = utracker,
      callback = function()
        vim.cmd 'UTrackerStop'
      end,
    })
    vim.api.nvim_create_autocmd({ 'FocusLost' }, {
      group = utracker,
      callback = function()
        vim.cmd 'UTrackerPause'
      end,
    })
    -- ... and resume when you're back in nvim as long as you're not in Insert mode
    vim.api.nvim_create_autocmd('FocusGained', {
      group = utracker,
      callback = function()
        vim.cmd 'UTrackerResume'
      end,
    })
  end,
}
