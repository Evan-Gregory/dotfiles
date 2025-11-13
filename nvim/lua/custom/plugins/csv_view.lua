return {
  {
    'hat0uma/csvview.nvim',
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      view = {
        display_mode = 'border',
        sticky_header = {
          enabled = true,
          separator = '─',
        },
      },
      parser = { comments = { '#', '//' } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
    },
    config = function(_, opts)
      require('csvview').setup(opts)

      local function enable_csvview()
        vim.cmd 'CsvViewEnable display_mode=border' -- this call lazy-loads the plugin
      end

      if vim.bo.filetype == 'csv' then
        enable_csvview()
      end

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*.csv',
        callback = function()
          enable_csvview()
        end,
      })
    end,
  },
}
