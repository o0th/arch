return {
  'neovim/nvim-lspconfig',
  dependencies = { 'saghen/blink.cmp' },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local lspconfig = require('lspconfig')

    lspconfig.lua_ls.setup({ capabilities = capabilities })
    lspconfig.zls.setup({ capabilities = capabilities })
    lspconfig.ts_ls.setup({ capabilities = capabilities })
    lspconfig.terraformls.setup({ capabilities = capabilities })

    local buffer_autoformat = function(bufnr)
      local group = 'lsp_autoformat'
      vim.api.nvim_create_augroup(group, { clear = false })
      vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        group = group,
        desc = 'LSP format on save',
        callback = function()
          -- note: do not enable async formatting
          vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
        end,
      })
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(event)
        local id = vim.tbl_get(event, 'data', 'client_id')
        local client = id and vim.lsp.get_client_by_id(id)
        if client == nil then
          return
        end

        if client.supports_method('textDocument/formatting') then
          buffer_autoformat(event.buf)
        end
      end
    })
  end
}