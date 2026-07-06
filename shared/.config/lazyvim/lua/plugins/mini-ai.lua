return {
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      -- taken from MiniExtra.gen_ai_spec.buffer
      local function ai_buffer(ai_type)
        local start_line, end_line = 1, vim.fn.line("$")
        if ai_type == "i" then
          -- Skip first and last blank lines for `i` textobject
          local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
          -- Do nothing for buffer with all blanks
          if first_nonblank == 0 or last_nonblank == 0 then
            return { from = { line = start_line, col = 1 } }
          end
          start_line, end_line = first_nonblank, last_nonblank
        end

        local to_col = math.max(vim.fn.getline(end_line):len(), 1)
        return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
      end
      local function ai_line(ai_type)
        local line_num = vim.fn.line(".")
        local line = vim.fn.getline(line_num)
        -- Ignore indentation for `i` textobject
        local from_col = ai_type == "a" and 1 or (line:match("^(%s*)"):len() + 1)
        -- Don't select `\n` past the line to operate within a line
        local to_col = line:len()

        return { from = { line = line_num, col = from_col }, to = { line = line_num, col = to_col } }
      end

      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          -- c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' }, -- class
          T = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          y = ai_line, -- line
          g = ai_buffer, -- buffer
          F = ai.gen_spec.function_call(), -- u for "Usage"
        },
      }
    end,
  },
}
