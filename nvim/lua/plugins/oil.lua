return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  keys = {
	  {'<leader>-', '<cmd>Oil<cr>', desc="[-] Oil"},
  },
  -- Optional dependencies
  dependencies = {  "nvim-mini/mini.icons" },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
