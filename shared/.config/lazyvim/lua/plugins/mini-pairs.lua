return {
  {
    "echasnovski/mini.pairs",
    opts = {
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][%s%\"'`%)}%]]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][%s%\"'`%)}%]]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][%s%\"'`%)}%]]" },
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = '[^\\"].', register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\'].", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\`].", register = { cr = false } },
      },
    },
  },
}
