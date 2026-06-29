return {
  {
    'lervag/wiki.vim',
    -- tag = "v0.10", -- uncomment to pin to a specific release
    init = function()
      -- wiki.vim configuration goes here, e.g.
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = function()
      require('lazy').load { plugins = { 'markdown-preview.nvim' } }
      vim.fn['mkdp#util#install']()
    end,
    keys = {
      {
        '<leader>cp',
        ft = 'markdown',
        '<cmd>MarkdownPreviewToggle<cr>',
        desc = 'Markdown Preview',
      },
      {
        '<leader>cP',
        ft = 'markdown',
        '<cmd>MarkdownPreview<cr>',
        desc = 'Markdown Preview (open)',
      },
      {
        '<leader>wp',
        '<cmd>WikiPages<cr>',
        desc = 'Wiki Pages',
      },
      {
        '<leader>wj',
        function()
          vim.cmd 'WikiJournal'
          local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
          -- Already has a header (existing entry) -> leave it alone
          if first_line:sub(1, 1) == '#' then
            return
          end
          local header = '# ' .. os.date '%Y-%m-%d'
          vim.api.nvim_buf_set_lines(0, 0, 1, true, { header, '' })
        end,
        desc = 'Wiki Pages',
      },
    },
    config = function()
      vim.cmd [[do FileType]]
    end,
  },
}
