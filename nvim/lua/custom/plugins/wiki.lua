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
        '<cmd>WikiJournal<cr>',
        desc = 'Wiki Pages',
      },
    },
    config = function()
      vim.cmd [[do FileType]]
    end,
  },
}
