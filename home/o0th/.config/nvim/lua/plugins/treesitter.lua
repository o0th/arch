return {
  'nvim-treesitter/nvim-treesitter',
  config = function()
    local treesitter = require('nvim-treesitter.configs')
    treesitter.setup({
      ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline' },
      highlight = { enable = true },
    })
  end,
}
