local deps = require('deps')

-- lsp
deps.add({
  src = deps.source.gh('neovim/nvim-lspconfig'),
})

-- lspeek: peek LSP definitions in a floating window
deps.add({
  src = deps.source.gh('r4ppz/lspeek.nvim'),
  data = {
    after = function(_)
      require('lspeek').setup({
        window = {
          width = 70,
          height = 15,
          border = 'single',
        },
        stack_limit = 5,
        select_first = true,
        keymaps = {
          close = 'q',
          split = 's',
          vsplit = 'v',
          enter = '<CR>',
          tab = 't',
        },
      })
    end,
  },
})

require('plugins.lsp.setup').setup()
