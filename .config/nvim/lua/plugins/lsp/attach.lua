local events = require('events')
local keys = require('keymaps')

local M = {}

local function supports(client, method, bufnr) return client and client:supports_method(method, bufnr) end

function M.setup()
  events.autocmd('LspAttach', {
    group = events.augroup('session_lsp', { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local methods = vim.lsp.protocol.Methods

      if supports(client, methods.textDocument_definition, bufnr) then
        keys.map(
          'n',
          '<leader>ld',
          '<CMD>Pick lsp scope="definition"<CR>',
          { buffer = bufnr, desc = 'Find definitions' }
        )
        keys.map(
          'n',
          'gD',
          function() require('lspeek').peek_definition() end,
          { buffer = bufnr, desc = 'Peek definition' }
        )
      end

      if supports(client, methods.textDocument_references, bufnr) then
        keys.map(
          'n',
          '<leader>lr',
          '<CMD>Pick lsp scope="references"<CR>',
          { buffer = bufnr, desc = 'Find references' }
        )
      end

      if supports(client, methods.textDocument_hover, bufnr) then
        keys.map(
          'n',
          '<leader>lh',
          function() vim.lsp.buf.hover() end,
          { buffer = bufnr, desc = 'Show hover information' }
        )
      end

      keys.map(
        'n',
        '<leader>ll',
        function() vim.diagnostic.open_float(0, { scope = 'line' }) end,
        { buffer = bufnr, desc = 'Show line diagnostics' }
      )

      if supports(client, methods.textDocument_rename, bufnr) then
        keys.map('n', '<leader>lcr', function() vim.lsp.buf.rename() end, { buffer = bufnr, desc = 'Rename symbol' })
      end

      if supports(client, methods.textDocument_codeAction, bufnr) then
        keys.map(
          { 'n', 'x' },
          '<leader>ca',
          function() require('tiny-code-action').code_action() end,
          { buffer = bufnr, desc = 'Code actions' }
        )
      end

      if supports(client, methods.textDocument_typeDefinition, bufnr) then
        keys.map(
          'n',
          'gT',
          function() require('lspeek').peek_type_definition() end,
          { buffer = bufnr, desc = 'Peek type definition' }
        )
      end
    end,
  })
end

return M
