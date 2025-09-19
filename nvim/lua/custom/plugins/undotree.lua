return {
  'mbbill/undotree',
  event = 'VeryLazy',
  config = function()
    vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<CR>', { desc = 'Telescope Undo' })
  end,
}
