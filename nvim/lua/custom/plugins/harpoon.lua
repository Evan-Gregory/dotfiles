-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    -- 1) Set up Harpoon
    local harpoon = require 'harpoon'
    require('harpoon'):setup()

    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values
    local ui = require 'harpoon.ui'

    local function toggle_telescope(harpoon_files, opts)
      local file_paths = {}
      opts = opts or {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      local make_finder = function()
        local paths = {}

        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end

        return require('telescope.finders').new_table {
          results = paths,
        }
      end

      pickers
        .new(opts, {
          prompt_title = 'Harpoon',
          finder = finders.new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_buffer_number, map)
            -- The keymap you need
            map('i', '<c-d>', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_buffer_number)

              -- This is the line you need to remove the entry
              harpoon:list():remove(selected_entry)
              current_picker:refresh(make_finder())
            end)

            return true
          end,
        })
        :find()
    end

    -- 3) Create a keymap for Telescope-based Harpoon menu
    vim.keymap.set('n', '<leader>a', function()
      toggle_telescope(
        harpoon:list(),
        require('telescope.themes').get_cursor {
          -- winblend = 0,
          layout_config = {
            height = 15,
            --   prompt_position = 'bottom',
          },
        }
      )
    end, { desc = 'Search Harpoon' })
  end,
  keys = {
    {
      '<leader>A',
      function()
        require('harpoon'):list():add()
      end,
      desc = 'Harpoon file',
    },
  },
}
