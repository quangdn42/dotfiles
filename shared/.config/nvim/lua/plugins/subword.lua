return {
  -- motions
  {
    'backdround/neowords.nvim',
    keys = function()
      local neowords = require 'neowords'
      local presets = neowords.pattern_presets

      local hops = neowords.get_word_hops(
        -- Vim-patterns or pattern presets separated by commas.
        -- Check `:h /magic` and onwards for patterns overview.
        -- All punctuation: '\\v[!\"#$%%&\'()*+,.\\-/:;<=>?@[\\]^{|}~]+'

        '\\v[!"#$%%&\'()*+,/:;<=>?@[\\]^{|}~]+',
        presets.number,
        presets.math_number,
        presets.snake_case,
        presets.camel_case,
        presets.upper_case,
        presets.hex_color
      )
      return {
        { 'w', hops.forward_start, mode = { 'n', 'x', 'o' } },
        { 'e', hops.forward_end, mode = { 'n', 'x', 'o' } },
        { 'b', hops.backward_start, mode = { 'n', 'x', 'o' } },
        { 'ge', hops.backward_end, mode = { 'n', 'x', 'o' } },
      }
    end,
  },

  -- textobjs
  {
    'Julian/vim-textobj-variable-segment',
    event = 'VeryLazy',
    dependencies = { 'kana/vim-textobj-user', config = function() end },
    config = function() end,
  },
}
