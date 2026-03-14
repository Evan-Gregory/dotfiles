return {
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    config = function()
      require('git-conflict').setup {
        default_mappings = false, -- we’ll add our own
        default_commands = true, -- gives you :GitConflict… commands
        disable_diagnostics = false, -- keep LSP diagnostics on
        debug = false, -- set to true to enable logging
        list_opener = 'copen', -- quickfix window for :GitConflictListQf
        highlights = { -- tweak colors if you like
          current = 'DiffText',
          incoming = 'DiffChange',
          ancestor = 'DiffAdd',
        },
      }

      -- clear hunk bg (no bg), highlight only labels/separator
      vim.api.nvim_set_hl(0, 'GitConflictCurrent', {})
      vim.api.nvim_set_hl(0, 'GitConflictIncoming', {})
      vim.api.nvim_set_hl(0, 'GitConflictAncestor', {})
      vim.api.nvim_set_hl(0, 'GitConflictSeparator', { bg = '#ececec', fg = 'cyan' })

      vim.api.nvim_set_hl(0, 'GitConflictCurrentLabel', { bg = '#e6f6e6', fg = '#1b3d20', bold = true })
      vim.api.nvim_set_hl(0, 'GitConflictIncomingLabel', { bg = '#fde7e7', fg = '#5a1414', bold = true })
      vim.api.nvim_set_hl(0, 'GitConflictAncestorLabel', { bg = '#e6eefc', fg = '#193a73', bold = true })

      -- navigation
      vim.keymap.set('n', ']x', '<cmd>GitConflictNextConflict<CR>', { desc = 'Next conflict' })
      vim.keymap.set('n', '[x', '<cmd>GitConflictPrevConflict<CR>', { desc = 'Prev conflict' })

      -- pick a side
      vim.keymap.set('n', '<leader>go', '<cmd>GitConflictChooseOurs<CR>', { desc = 'Choose [O]URS' })
      vim.keymap.set('n', '<leader>gt', '<cmd>GitConflictChooseTheirs<CR>', { desc = 'Choose [T]HEIRS' })
      vim.keymap.set('n', '<leader>gb', '<cmd>GitConflictChooseBoth<CR>', { desc = 'Choose [B]OTH' })
      vim.keymap.set('n', '<leader>g0', '<cmd>GitConflictChooseNone<CR>', { desc = 'Choose NONE' })

      -- utilities
      vim.keymap.set('n', '<leader>gx', '<cmd>GitConflictListQf<CR>', { desc = 'List conflicts (qf)' })
      vim.keymap.set('n', '<leader>gr', '<cmd>GitConflictRefresh<CR>', { desc = '[R]efresh conflict state' })
    end,
  },
}
