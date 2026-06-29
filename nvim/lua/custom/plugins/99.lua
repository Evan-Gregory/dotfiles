return {
  {
    'ThePrimeagen/99',
    config = function()
      local _99 = require '99'

      -- For logging that is to a file if you wish to trace through requests
      -- for reporting bugs, i would not rely on this, but instead the provided
      -- logging mechanisms within 99.  This is for more debugging purposes
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
      _99.setup {
        provider = _99.Providers.ClaudeCodeProvider, -- default: OpenCodeProvider
        model = 'claude-sonnet-4-6', -- or "anthropic/claude-sonnet-4-6"
        logger = {
          level = _99.DEBUG,
          path = '/tmp/' .. basename .. '.99.debug',
          print_on_error = true,
        },
        -- When setting this to something that is not inside the CWD tools
        -- such as claude code or opencode will have permission issues
        -- and generation will fail refer to tool documentation to resolve
        -- https://opencode.ai/docs/permissions/#external-directories
        -- https://code.claude.com/docs/en/permissions#read-and-edit
        tmp_dir = './tmp',

        --- Completions: #rules and @files in the prompt buffer
        completion = {
          -- I am going to disable these until i understand the
          -- problem better.  Inside of cursor rules there is also
          -- application rules, which means i need to apply these
          -- differently
          -- cursor_rules = "<custom path to cursor rules>"

          --- A list of folders where you have your own SKILL.md
          --- Expected format:
          --- /path/to/dir/<skill_name>/SKILL.md
          ---
          --- Example:
          --- Input Path:
          --- "scratch/custom_rules/"
          ---
          --- Output Rules:
          --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
          --- ... the other rules in that dir ...
          ---
          custom_rules = {
            '~/.claude/skills/',
          },

          --- Configure @file completion (all fields optional, sensible defaults)
          files = {
            enabled = true,
            max_file_size = 102400, -- bytes, skip files larger than this
            max_files = 5000, -- cap on total discovered files
            exclude = { '.env', '.env.*', 'node_modules', '.git' },
          },

          --- What autocomplete do you use.  We currently only
          --- support cmp right now
          source = 'cmp',
        },

        --- WARNING: if you change cwd then this is likely broken
        --- ill likely fix this in a later change
        ---
        --- md_files is a list of files to look for and auto add based on the location
        --- of the originating request.  That means if you are at /foo/bar/baz.lua
        --- the system will automagically look for:
        --- /foo/bar/AGENT.md
        --- /foo/AGENT.md
        --- assuming that /foo is project root (based on cwd)
        md_files = {
          'AGENTS.md',
        },
      }

      -- take extra note that i have visual selection only in v mode
      -- technically whatever your last visual selection is, will be used
      -- so i have this set to visual mode so i dont screw up and use an
      -- old visual selection
      --
      -- likely ill add a mode check and assert on required visual mode
      -- so just prepare for it now
      vim.keymap.set('v', '<leader>9v', function()
        _99.visual()
      end)

      --- if you have a request you dont want to make any changes, just cancel it
      vim.keymap.set('n', '<leader>9x', function()
        _99.stop_all_requests()
      end)

      vim.keymap.set('n', '<leader>9s', function()
        _99.search()
      end)

      vim.keymap.set('v', '<leader>9d', function()
        _99.visual {
          additional_prompt = 'Using the highlighted section as your target, write a docstring',
          additional_rules = { name = 'docstring_writer', path = '~/.claude/skills/docstring_writer/SKILL.md' },
        }
      end)

      vim.keymap.set('v', '<leader>9c', function()
        -- Exit visual mode so '< '> marks are committed
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

        local start_pos = vim.fn.getpos "'<"
        local end_pos = vim.fn.getpos "'>"
        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]

        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        local selection = ''
        if #lines > 0 then
          if end_col >= 2147483647 then
            end_col = #lines[#lines]
          end
          lines[#lines] = lines[#lines]:sub(1, end_col)
          lines[1] = lines[1]:sub(start_col)
          selection = table.concat(lines, '\n')
        end

        local prompt = 'Follow the smart-commit skill exactly. Do not read any files or search the codebase. Only run git commands and commit.'
        if selection ~= '' then
          prompt = prompt .. '\n\n<HighlightedContext>\n' .. selection .. '\n</HighlightedContext>'
        end

        _99.vibe {
          additional_rules = {
            { name = 'smart-commit', path = '~/.claude/skills/smart-commit/SKILL.md' },
          },
          additional_prompt = prompt,
        }
      end)

      vim.keymap.set('n', '<leader>to', function()
        local stdout_data = {}
        local stderr_data = {}

        vim.fn.jobstart({ 'claude', '-p', '/test-outline' }, {
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data)
            stdout_data = data or {}
          end,
          on_stderr = function(_, data)
            stderr_data = data or {}
          end,
          on_exit = function(_, code)
            vim.schedule(function()
              if code ~= 0 then
                local err = table.concat(
                  vim.tbl_filter(function(l) return l ~= '' end, stderr_data),
                  '\n'
                )
                vim.notify('test-outline failed:\n' .. err, vim.log.levels.ERROR)
                return
              end

              local summary = {}
              local entries = {}
              for _, line in ipairs(stdout_data) do
                if line == '' then
                elseif line:sub(1, 1) == '#' then
                  table.insert(summary, line)
                else
                  table.insert(entries, line)
                end
              end

              if #summary > 0 then
                vim.notify(table.concat(summary, '\n'), vim.log.levels.INFO)
              end

              vim.fn.setqflist({}, 'r', { title = 'Test Outline', efm = '%f:%l: %m', lines = entries })
              vim.cmd 'copen'
              vim.notify('Test outline ready — ' .. #vim.fn.getqflist() .. ' items')
            end)
          end,
        })
      end)
    end,
  },
}
