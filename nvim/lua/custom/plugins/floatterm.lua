return {
  'voldikss/vim-floaterm',
  keys = {
    { '<leader>tt', '<cmd>FloatermNew --height=0.2 --width=0.9 --autoclose=1 --wintype=float <CR>' },
    { '<leader>tl', '<cmd>FloatermNew --height=0.9 --width=0.9 --wintype=float lazygit<CR>' },
  },
}
