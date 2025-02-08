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

    -- 2) Define a custom Telescope picker for Harpoon
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files, opts)
      local file_paths = {}
      opts = opts or {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      pickers
        .new(opts, {
          prompt_title = 'Harpoon',
          finder = finders.new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter(opts),
        })
        :find()
    end

    -- 3) Create a keymap for Telescope-based Harpoon menu
    vim.keymap.set('n', '<leader>a', function()
      toggle_telescope(
        harpoon:list(),
        require('telescope.themes').get_ivy {
          winblend = 10,
          layout_config = {
            height = 15,
            prompt_position = 'bottom',
          },
        }
      )
    end, { desc = 'Open Harpoon via Telescope' })
  end,
  keys = {
    {
      '<leader>A',
      function()
        require('harpoon'):list():add()
      end,
      desc = 'Harpoon file',
    },
    {
      '<leader>a',
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list(), { border = 'none' })
      end,
      desc = 'Harpoon quick menu',
    },
    --    {
    --      '<leader>h1',
    --      function()
    --        require('harpoon'):list('task1'):select()
    --      end,
    --      desc = 'Harpoon to file 1',
    --    },
    --    {
    --      '<leader>h2',
    --      function()
    --        require('harpoon'):list('task2'):select()
    --      end,
    --      desc = 'Harpoon to file 2',
    --    },
    {
      '<leader>1',
      function()
        require('harpoon'):list():select(1)
      end,
      desc = 'Harpoon to file 1',
    },
    {
      '<leader>2',
      function()
        require('harpoon'):list():select(2)
      end,
      desc = 'Harpoon to file 2',
    },
    {
      '<leader>3',
      function()
        require('harpoon'):list():select(3)
      end,
      desc = 'Harpoon to file 3',
    },
    {
      '<leader>4',
      function()
        require('harpoon'):list():select(4)
      end,
      desc = 'Harpoon to file 4',
    },
    {
      '<leader>5',
      function()
        require('harpoon'):list():select(5)
      end,
      desc = 'Harpoon to file 5',
    },
  },
}
