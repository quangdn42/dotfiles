local ui_events = { "BufReadPre", "BufNewFile" }
return {
  {
    "b0o/incline.nvim",
    event = ui_events,
    enabled = true,
    config = function()
      require("incline").setup({
        window = { margin = { vertical = 0, horizontal = 0 } },
        render = function(props)
          local devicons = require("nvim-web-devicons")
          local lzicons = LazyVim.config.icons
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          local colors = require("tokyonight.colors").setup({ style = "moon" })

          local function get_git_diff()
            local icons = {
              removed = lzicons.git.removed,
              changed = lzicons.git.modified,
              added = lzicons.git.added,
            }
            local signs = vim.b[props.buf].gitsigns_status_dict
            local labels = {}
            if signs == nil then
              return labels
            end
            for name, icon in pairs(icons) do
              if tonumber(signs[name]) and signs[name] > 0 then
                table.insert(labels, { icon .. signs[name] .. " ", group = "Diff" .. name })
              end
            end
            if #labels > 0 then
              table.insert(labels, { "┊ " })
            end
            return labels
          end

          local function get_diagnostic_label()
            local icons = {
              error = lzicons.diagnostics.Error,
              warn = lzicons.diagnostics.Warn,
              info = lzicons.diagnostics.Info,
              hint = lzicons.diagnostics.Hint,
            }
            local label = {}

            for severity, icon in pairs(icons) do
              local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
              if n > 0 then
                table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
              end
            end
            if #label > 0 then
              table.insert(label, { "┊ " })
            end
            return label
          end

          return {
            { get_diagnostic_label() },
            { get_git_diff() },
            { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
            { filename },
            { modified and " ●" or "", guifg = colors.yellow },
          }
        end,
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    enabled = false,
    opts = {
      options = {
        right_mouse_command = false,
        middle_mouse_command = "bdelete! %d",
        -- separator_style = "slant",
      },
    },
  },

  -- Auto resize focused splits
  {
    "nvim-focus/focus.nvim",
    event = ui_events,
    opts = {
      commands = true,
      ui = {
        cursorline = false,
        signcolumn = false,
      },
    },
    config = function()
      local ignore_filetypes = { "snacks_picker" }
      local ignore_buftypes = { "nofile", "prompt", "popup" }

      local augroup = vim.api.nvim_create_augroup("FocusDisable", { clear = true })

      vim.api.nvim_create_autocmd("WinEnter", {
        group = augroup,
        callback = function(_)
          if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
            vim.w.focus_disable = true
          else
            vim.w.focus_disable = false
          end
        end,
        desc = "Disable focus autoresize for BufType",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        callback = function(_)
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.focus_disable = true
          else
            vim.b.focus_disable = false
          end
        end,
        desc = "Disable focus autoresize for FileType",
      })
    end,
    keys = {
      { "<leader>uW", "<cmd>FocusToggle<cr>", desc = "Toggle Window Focus" },
    },
  },

  -- smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = ui_events,
    opts = {
      duration_multiplier = 0.2,
    },
  },
}
