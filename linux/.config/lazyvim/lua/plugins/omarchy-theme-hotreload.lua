local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

local function theme_signature()
  local stat = (vim.uv or vim.loop).fs_stat(theme_file)
  if not stat then
    return "missing"
  end

  return table.concat({ theme_file, stat.mtime.sec, stat.mtime.nsec or 0, stat.size }, ":")
end

local function plugin_key(spec)
  if type(spec) ~= "table" then
    return nil
  end

  if type(spec.name) == "string" then
    return spec.name
  end

  if type(spec[1]) == "string" then
    return spec[1]:match("/([^/]+)$") or spec[1]
  end
end

local function parse_theme(specs)
  local colorscheme
  local plugin_name

  for _, spec in ipairs(specs) do
    if type(spec) == "table" and spec[1] == "LazyVim/LazyVim" and type(spec.opts) == "table" then
      colorscheme = spec.opts.colorscheme or colorscheme
    elseif type(spec) == "table" then
      plugin_name = plugin_name or plugin_key(spec)
    end
  end

  return colorscheme, plugin_name
end

return {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local transparency_file = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"
      local last_signature = theme_signature()

      local function apply_theme(force)
        local signature = theme_signature()
        if not force and signature == last_signature then
          return
        end
        last_signature = signature

        package.loaded["plugins.theme"] = nil
        local ok_theme, theme_spec = pcall(require, "plugins.theme")
        if not ok_theme or type(theme_spec) ~= "table" then
          return
        end

        local colorscheme, plugin_name = parse_theme(theme_spec)
        if not colorscheme then
          return
        end

        local lazy_config = require("lazy.core.config")
        local loader = require("lazy.core.loader")
        local plugin = plugin_name and lazy_config.plugins[plugin_name]
        if plugin and plugin._ and plugin._.loaded then
          local ok_reload, err = pcall(loader.reload, plugin)
          if not ok_reload then
            vim.notify(("Failed to reload theme plugin %s: %s"):format(plugin_name, err), vim.log.levels.WARN)
          end
        end

        loader.colorscheme(colorscheme)

        local ok_colorscheme, err = pcall(vim.cmd.colorscheme, colorscheme)
        if not ok_colorscheme then
          vim.notify(("Failed to apply colorscheme %s: %s"):format(colorscheme, err), vim.log.levels.WARN)
          return
        end

        if vim.fn.filereadable(transparency_file) == 1 then
          pcall(vim.cmd.source, transparency_file)
        end

        vim.cmd("redraw!")
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          vim.schedule(function()
            apply_theme(false)
          end)
        end,
      })
    end,
  },
}
