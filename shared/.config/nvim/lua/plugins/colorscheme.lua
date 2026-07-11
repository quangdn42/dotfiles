local fallback = {
  {
    'folke/tokyonight.nvim',
    enabled = true,
    version = '*',
    -- commit = 'c8ea87c',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
    opts = {
      transparent = false,
      on_highlights = function(hl, colors)
        hl['SnacksDashboardHeader'] = { fg = colors.blue2 }
        hl['WinBar'] = { bg = colors.bg }
        hl['WinBarNC'] = { bg = colors.bg }
        -- Link the treesitter capture for Python docstrings to the Comment group.
        -- hl['@string.documentation.python'] = { link = 'Comment' }
      end,
      on_colors = function(colors)
        colors.border = colors.blue2
      end,
    },
  },
  {
    'rebelot/kanagawa.nvim',
    enabled = false,
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'kanagawa'
    end,
    opts = {
      compile = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        local palette = colors.palette
        return {
          -- Flash
          FlashLabel = { fg = palette.lotusCyan, bg = palette.samuraiRed, bold = true },
          FlashMatch = { fg = palette.lotusCyan, bg = palette.lotusBlue4 },
          FlashCurrent = { fg = palette.sumiInk2, bg = palette.surimiOrange },
          -- Eyeliner
          EyelinerPrimary = { fg = palette.surimiOrange },
          EyelinerSecondary = { fg = palette.springBlue },
          -- Dark completion menu
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend }, -- add `blend = vim.o.pumblend` to enable transparency
          PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
        }
      end,
    },
  },
  {
    'catppuccin/nvim',
    enabled = false,
    name = 'catppuccin',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
    opts = {
      dim_inactive = { enabled = false },
      integration = {
        cmp = false,
        blink_cmp = true,
        diffview = true,
      },
      custom_highlights = function(colors)
        return {
          FlashLabel = { fg = colors.crust, bg = colors.red, style = { 'bold' } },
          -- FlashLabel = { fg = colors.red },
          FlashMatch = { fg = colors.text, bg = '#355868' },
          FlashCurrent = { fg = colors.crust, bg = colors.sky },
          -- InclineNormal = { bg = colors.rosewater, fg = colors.crust },
          InclineNormal = { fg = colors.peach, bg = colors.crust },
          CmpItemAbbrMatch = { fg = colors.blue },
          CmpItemAbbr = { fg = colors.text },
          PmenuBorder = { bg = colors.text },
        }
      end,
    },
  },
}

local function omarchy_theme()
  if (vim.uv or vim.loop).os_uname().sysname ~= 'Linux' then
    return nil
  end

  local theme_file = vim.fn.expand '~/.config/omarchy/current/theme/neovim.lua'
  if vim.fn.filereadable(theme_file) ~= 1 then
    return nil
  end

  local chunk = loadfile(theme_file)
  if not chunk then
    return nil
  end

  local ok, theme = pcall(chunk)
  if not ok or type(theme) ~= 'table' then
    return nil
  end

  local colorscheme
  local specs = {}
  for _, spec in ipairs(theme) do
    if type(spec) == 'table' then
      if spec[1] == 'LazyVim/LazyVim' then
        colorscheme = spec.opts and spec.opts.colorscheme
      else
        table.insert(specs, vim.deepcopy(spec))
      end
    end
  end

  if not colorscheme or #specs == 0 then
    return nil
  end

  for _, spec in ipairs(specs) do
    spec.lazy = false
    spec.priority = spec.priority or 1000
  end

  local theme_spec = specs[1]
  if type(theme_spec.config) ~= 'function' then
    local init = theme_spec.init
    theme_spec.init = function(...)
      if type(init) == 'function' then
        init(...)
      end
      vim.cmd.colorscheme(colorscheme)
    end
  end

  return specs
end

return omarchy_theme() or fallback
-- vim: ts=2 sts=2 sw=2 et
