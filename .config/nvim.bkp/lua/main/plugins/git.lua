local deps = require('main.plugins.deps')
local keys = require('main.core.keymaps')

-- neogit
deps.later(function()
  deps.add({ source = 'NeogitOrg/neogit', depends = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' } })

  require('neogit').setup({})

  keys.map('n', '<leader>gg', function() require('neogit').open() end, { desc = 'Open Neogit' })
end)

-- signs
deps.later(function()
  deps.add({
    source = 'lewis6991/gitsigns.nvim',
  })

  require('gitsigns').setup()

  keys.map('n', '<leader>gb', function() require('gitsigns').blame_line({ full = true }) end, { desc = 'Blame line' })
  keys.map(
    'n',
    '<leader>gB',
    function() require('gitsigns').toggle_current_line_blame() end,
    { desc = 'Toggle blame line' }
  )
end)
