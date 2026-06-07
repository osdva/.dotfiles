local deps = require('deps')
local lsp_config = require('plugins.lsp.config')

-- installer
deps.add({
  src = deps.source.gh('mason-org/mason.nvim'),
  data = {
    after = function(_)
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      })
    end,
  },
})

-- external tool installer
deps.add({
  src = deps.source.gh('WhoIsSethDaniel/mason-tool-installer.nvim'),
  data = {
    after = function(_)
      local ensure_installed = vim.list_slice(lsp_config.tools)

      for _, mason_package in pairs(lsp_config.servers) do
        table.insert(ensure_installed, mason_package)
      end

      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
      })
    end,
  },
})
