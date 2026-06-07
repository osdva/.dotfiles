local config = require('plugins.lsp.config')

local M = {}

function M.setup()
  require('plugins.lsp.attach').setup()

  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  })

  vim.lsp.enable(vim.tbl_keys(config.servers))

  vim.diagnostic.config({
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
      },
    },
  })
end

return M
