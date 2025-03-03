return {
  {
    'echasnovski/mini.surround',
    opts = {
      mappings = {
        add = 's', -- Add surrounding in Normal and Visual modes
        delete = 'ds', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'cs', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    },
  },
  {
    'echasnovski/mini.sessions',
    version = false,
    opts = { autoread = false },
    config = function(_, opts)
      require('mini.sessions').setup(opts)
    end,
    keys = {
      { '<leader>S', '<cmd>mksession<cr>', desc = 'Saves current session' },
    },
  },
}
