local deps = require('deps')

-- treesitter
deps.add({
  src = deps.source.gh('romus204/tree-sitter-manager.nvim'),
  data = {
    after = function(_)
      require('tree-sitter-manager').setup({
        ensure_installed = {
          'astro',
          'bash',
          'css',
          'diff',
          'elixir',
          'fish',
          'gitcommit',
          'html',
          'javascript',
          'json',
          'json5',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'query',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
        },
        auto_install = true,
        highlight = true,
      })
    end,
  },
})

-- autotag
deps.add({
  src = deps.source.gh('windwp/nvim-ts-autotag'),
  data = {
    after = function(_)
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },
})
