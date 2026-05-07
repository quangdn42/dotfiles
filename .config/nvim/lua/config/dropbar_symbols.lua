local M = {}

local function get_sources(buf)
  local sources = require 'dropbar.sources'

  if vim.bo[buf].filetype == 'markdown' then
    return { { source = sources.markdown, mode = 'markdown' } }
  end

  return {
    { source = sources.lsp, mode = 'lsp' },
    { source = sources.treesitter, mode = 'treesitter' },
  }
end

local function get_symbols(source, buf, win, cursor)
  local ok, symbols = pcall(source.get_symbols, buf, win, cursor)
  return ok and symbols or {}
end

local function get_symbol_list(symbol, key)
  local ok, value = pcall(function()
    return symbol[key]
  end)

  return ok and value or {}
end

local function get_symbol_range(symbol)
  local ok, range = pcall(function()
    return symbol.range
  end)

  return ok and range or nil
end

local function symbol_kind(symbol)
  local kind = (symbol.name_hl or ''):match '^DropBarKind(.+)$' or (symbol.icon_hl or ''):match '^DropBarIconKind(.+)$' or 'Unknown'

  return kind:match '^MarkdownH%d+$' and 'Text' or kind
end

local function symbol_roots(symbols)
  local root = symbols[1]
  if not root then
    return {}
  end

  local siblings = get_symbol_list(root, 'siblings')
  return #siblings > 0 and siblings or { root }
end

local function first_nonblank_col(line)
  return (line:find '%S' or 1) - 1
end

local function source_roots(source, buf, win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local roots = symbol_roots(get_symbols(source, buf, win, cursor))
  if #roots > 0 then
    return roots
  end

  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    roots = symbol_roots(get_symbols(source, buf, win, { lnum, first_nonblank_col(line) }))
    if #roots > 0 then
      return roots
    end
  end

  return {}
end

local function find_root_sets(buf, win)
  local root_sets = {}

  for _, source in ipairs(get_sources(buf)) do
    local roots = source_roots(source.source, buf, win)
    if #roots > 0 then
      root_sets[#root_sets + 1] = { roots = roots, mode = source.mode }
    end
  end

  return root_sets
end

local function normal_win_for_buf(buf, fallback)
  if vim.api.nvim_win_is_valid(fallback) and vim.api.nvim_win_get_buf(fallback) == buf then
    return fallback
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      return win
    end
  end

  return fallback
end

local function range_key(range, kind, name)
  return ('%s:%s:%d:%d:%d:%d'):format(kind, name, range.start.line, range.start.character, range['end'].line, range['end'].character)
end

local function symbol_path(parent, name)
  local parts = { name }
  while parent and not parent.root do
    table.insert(parts, 1, parent.name)
    parent = parent.parent
  end
  return table.concat(parts, ' ')
end

local function restore_preview(picker, restore_view)
  local state = picker._dropbar_symbols_preview
  if not state or not state.symbol then
    return
  end

  pcall(state.symbol.preview_restore_hl, state.symbol)
  if restore_view ~= false then
    pcall(state.symbol.preview_restore_view, state.symbol)
  end
  picker._dropbar_symbols_preview = nil
end

function M.finder(opts, ctx)
  local buf = opts.buf or ctx.filter.current_buf
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return {}
  end

  local win = normal_win_for_buf(buf, ctx.filter.current_win)
  if not vim.api.nvim_win_is_valid(win) then
    return {}
  end

  local root_sets = find_root_sets(buf, win)
  local root = { text = '', root = true }
  local last = {}
  local seen = {}
  local items = {}

  local function add(symbol, parent, mode)
    if not symbol then
      return
    end

    local range = get_symbol_range(symbol)
    local raw_name = vim.trim(symbol.name or '')
    if not range or not range.start or not range['end'] or raw_name == '' then
      return
    end

    local kind = symbol_kind(symbol)
    local name = raw_name
    local item_parent = parent
    local key = range_key(range, kind, name)

    if not seen[key] then
      seen[key] = true

      local item = {
        buf = buf,
        kind = kind,
        lsp_kind = kind,
        name = name,
        parent = parent,
        pos = { range.start.line + 1, range.start.character },
        end_pos = { range['end'].line + 1, range['end'].character },
        text = table.concat({ kind, symbol_path(parent, name) }, ' '),
        tree = opts.tree ~= false,
        dropbar_source = mode,
        item = symbol,
        symbol = symbol,
      }

      if last[parent] then
        last[parent].last = false
      end
      last[parent] = item
      item.last = true
      items[#items + 1] = item
      item_parent = item
    end

    for _, child in ipairs(get_symbol_list(symbol, 'children')) do
      add(child, item_parent, mode)
    end
  end

  for _, root_set in ipairs(root_sets) do
    for _, symbol in ipairs(root_set.roots) do
      add(symbol, root, root_set.mode)
    end
  end

  return items
end

function M.format(item, picker)
  local ret = {}

  if item.tree then
    vim.list_extend(ret, Snacks.picker.format.tree(item, picker))
  end

  local symbol = item.symbol
  if symbol then
    ret[#ret + 1] = { symbol.icon or '', symbol.icon_hl }
    ret[#ret + 1] = { item.name, symbol.name_hl }
    return ret
  end

  return Snacks.picker.format.lsp_symbol(item, picker)
end

function M.preview(picker, item)
  if not item or not item.symbol then
    restore_preview(picker)
    return
  end

  local state = picker._dropbar_symbols_preview or {}
  if state.symbol == item.symbol then
    return
  end

  if state.symbol then
    pcall(state.symbol.preview_restore_hl, state.symbol)
  end

  pcall(item.symbol.preview, item.symbol, state.view)
  picker._dropbar_symbols_preview = {
    symbol = item.symbol,
    view = item.symbol.view,
  }
end

function M.close_preview(picker)
  restore_preview(picker)
end

return M
