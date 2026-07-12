local theme_module = 'omarchy.theme'

local function load_theme()
  package.loaded[theme_module] = nil

  local ok, specs = pcall(require, theme_module)
  if not ok or type(specs) ~= 'table' then
    return {}
  end

  return specs
end

local function parse_theme(specs)
  local plugin_specs = {}
  local colorscheme
  local plugin_name

  for _, spec in ipairs(specs) do
    if type(spec) == 'table' and type(spec.opts) == 'table' and spec.opts.colorscheme ~= nil then
      colorscheme = spec.opts.colorscheme
    elseif type(spec) == 'table' then
      plugin_specs[#plugin_specs + 1] = spec
      plugin_name = plugin_name or spec.name or spec[1]
    end
  end

  return plugin_specs, colorscheme, plugin_name
end

local function theme_specs()
  local plugin_specs = parse_theme(load_theme())

  plugin_specs[#plugin_specs + 1] = {
    name = 'theme-hotreload',
    dir = vim.fn.stdpath 'config',
    lazy = false,
    priority = 1000,
    config = function()
      local transparency_file = vim.fn.stdpath 'config' .. '/plugin/after/transparency.lua'

      local function apply_theme()
        local _, colorscheme, plugin_name = parse_theme(load_theme())
        if not colorscheme then
          return
        end

        vim.cmd 'highlight clear'
        if vim.fn.exists 'syntax_on' then
          vim.cmd 'syntax reset'
        end

        -- Reset background so light themes can set it explicitly.
        vim.o.background = 'dark'

        if plugin_name then
          local plugin = require('lazy.core.config').plugins[plugin_name]
          if plugin then
            require('lazy.core.util').walkmods(plugin.dir .. '/lua', function(modname)
              package.loaded[modname] = nil
              package.preload[modname] = nil
            end)
          end
        end

        require('lazy.core.loader').colorscheme(colorscheme)

        vim.defer_fn(function()
          pcall(vim.cmd.colorscheme, colorscheme)
          vim.cmd 'redraw!'

          if vim.fn.filereadable(transparency_file) == 1 then
            vim.defer_fn(function()
              vim.cmd.source(transparency_file)
              vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false })
              vim.api.nvim_exec_autocmds('VimEnter', { modeline = false })
              vim.cmd 'redraw!'
            end, 5)
          end
        end, 5)
      end

      apply_theme()

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyReload',
        callback = function()
          vim.schedule(apply_theme)
        end,
      })
    end,
  }

  return plugin_specs
end

return {
  {
    name = theme_module,
    import = theme_specs,
  },
}
-- vim: ts=2 sts=2 sw=2 et
