return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    config = function()
      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#44475A' }) -- Dracula selection/current-line
        vim.api.nvim_set_hl(0, 'IblScope', { fg = '#6272A4' }) -- Dracula comment purple
      end)
      require('ibl').setup {
        indent = { highlight = 'IblIndent' },
        scope = { highlight = 'IblScope' },
      }
    end,
  },
}
