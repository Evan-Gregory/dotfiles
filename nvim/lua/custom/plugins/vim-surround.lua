return {
  --  {
  --    'tpope/vim-surround',
  --  },
  --  {
  --    'kana/vim-textobj-user',
  --  },
  {
    --    'lukas-reineke/indent-blankline.nvim',
    --    main = 'ibl',
    --    event = 'BufReadPost',
    --    ---@module "ibl"
    --    ---@type ibl.config
    --    opts = {
    --      scope = {
    --        show_start = false,
    --        show_end = false,
    --      },
    --      config = function(_, opts) end,
    --    },
  },

  {
    'shellRaining/hlchunk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local cb = function()
        if vim.g.colors_name == 'tokyonight' then
          return '#806d9c'
        else
          return '#00ffff'
        end
      end
      require('hlchunk').setup {
        chunk = { enable = true },
        indent = { enable = true },
      }
    end,
  },
  --  { 'stevearc/dressing.nvim' },
  -- lazy.nvim

  --  --{
  --  --  'Julian/vim-textobj-variable-segment',
  --  --},
}
