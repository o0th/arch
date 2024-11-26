local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local function is_visible(cmp) return cmp.core.view:visible() or vim.fn.pumvisible() == 1 end

return {
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'hrsh7th/cmp-cmdline' },
      { 'hrsh7th/cmp-buffer' },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ["<CR>"] = cmp.mapping(cmp.mapping.confirm { select = false }, { "i", "c" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if is_visible(cmp) then
              cmp.select_next_item()
            elseif vim.api.nvim_get_mode().mode ~= "c" and vim.snippet and vim.snippet.active { direction = 1 } then
              vim.schedule(function() vim.snippet.jump(1) end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if is_visible(cmp) then
              cmp.select_prev_item()
            elseif vim.api.nvim_get_mode().mode ~= "c" and vim.snippet and vim.snippet.active { direction = -1 } then
              vim.schedule(function() vim.snippet.jump(-1) end)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
    },
    init = function()
      vim.opt.signcolumn = 'yes'
    end,
    config = function()
      local lsp_defaults = require('lspconfig').util.default_config

      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }

          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end,
      })

      -- lua_ls
      require('lspconfig').lua_ls.setup({
        settings = {
          Lua = {
            telemetry = {
              enable = false
            },
          },
        },
        on_init = function(client)
          local join = vim.fs.joinpath
          local path = client.workspace_folders[1].name

          -- Don't do anything if there is project local config
          if vim.uv.fs_stat(join(path, '.luarc.json'))
              or vim.uv.fs_stat(join(path, '.luarc.jsonc'))
          then
            return
          end

          -- Apply neovim specific settings
          local runtime_path = vim.split(package.path, ';')
          table.insert(runtime_path, join('lua', '?.lua'))
          table.insert(runtime_path, join('lua', '?', 'init.lua'))

          local nvim_settings = {
            runtime = {
              -- Tell the language server which version of Lua you're using
              version = 'LuaJIT',
              path = runtime_path
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' }
            },
            workspace = {
              checkThirdParty = false,
              library = {
                -- Make the server aware of Neovim runtime files
                vim.env.VIMRUNTIME,
                vim.fn.stdpath('config'),
              },
            },
          }
          client.config.settings.Lua = vim.tbl_deep_extend(
            'force',
            client.config.settings.Lua,
            nvim_settings
          )
        end,
      })

      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

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
  },
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
  }
}