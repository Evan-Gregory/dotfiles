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
  {
    'folke/noice.nvim',
    priority = 500,
    event = 'VeryLazy',
    opts = {
      lsp = {
        hover = {
          enabled = false,
        },
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  --  --{
  --  --  'Julian/vim-textobj-variable-segment',
  --  --},
}
