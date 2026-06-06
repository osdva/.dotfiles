local deps = require('main.plugins.deps')

deps.later(function()
  deps.add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'master',
    monitor = 'main',
    hooks = {
      post_checkout = function() vim.cmd('TSUpdate') end,
    },
  })

  local ensure_installed = {
    'bash',
    'diff',
    'html',
    'css',
    'gitcommit',
    'json',
    'json5',
    'lua',
    'luadoc',
    'markdown',
    'vim',
    'elixir',
    'javascript',
    'typescript',
    'tsx',
  }

  require('nvim-treesitter.configs').setup({
    ensure_installed = ensure_installed,
    modules = {},
    ignore_install = {},
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  })
end)
