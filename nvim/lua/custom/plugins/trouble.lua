return {
  'folke/trouble.nvim',
  opts = {
    modes = {
      mode = 'Symbols',
      preview = {
        type = 'split',
        relative = 'win',
        position = 'right',
        size = 0.2,
      },
    },
  }, -- for default options, refer to the configuration section for custom setup.
  config = function(_, opts)
    vim.api.nvim_set_hl(0, 'TroubleNormal', { fg = '#c8d3f5' })
    vim.api.nvim_set_hl(0, 'TroubleNormalNC', { fg = '#c8d3f5' })
    require('trouble').setup(opts)
  end,
  cmd = 'Trouble',
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle focus=true win.size=.2 winblend=10<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
  },
}
