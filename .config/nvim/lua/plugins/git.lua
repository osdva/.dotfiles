local deps = require('deps')
local keys = require('keymaps')

-- codediff
deps.add({
  src = deps.source.gh('esmuellert/codediff.nvim'),
  data = {
    after = function(_)
      require('codediff').setup({
        diff = {
          layout = 'inline',
        },
        explorer = {
          view_mode = 'tree',
        },
      })

      keys.map('n', '<leader>gd', '<CMD>CodeDiff<CR>', { desc = 'Open CodeDiff' })
      keys.map('n', '<leader>gH', '<CMD>CodeDiff history<CR>', { desc = 'Open CodeDiff history' })
    end,
  },
})

-- neogit
deps.add({
  src = deps.source.gh('NeogitOrg/neogit'),
  data = {
    after = function(_)
      require('neogit').setup({})

      keys.map('n', '<leader>gg', function() require('neogit').open() end, { desc = 'Open Neogit' })
    end,
  },
})

-- signs
deps.add({
  src = deps.source.gh('lewis6991/gitsigns.nvim'),
  data = {
    after = function(_)
      require('gitsigns').setup({})

      keys.map(
        'n',
        '<leader>gb',
        function() require('gitsigns').blame_line({ full = true }) end,
        { desc = 'Blame line' }
      )
      keys.map(
        'n',
        '<leader>gB',
        function() require('gitsigns').toggle_current_line_blame() end,
        { desc = 'Toggle blame line' }
      )
    end,
  },
})
