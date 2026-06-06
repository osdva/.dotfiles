local deps = require('main.plugins.deps')
local keys = require('main.core.keymaps')

deps.later(function()
  deps.add({
    source = 'nvim-neotest/neotest',
    depends = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',

      -- adapters
      'marilari88/neotest-vitest',
      'nvim-neotest/neotest-jest',
      'jfpedroza/neotest-elixir',
    },
  })

  require('neotest').setup({
    adapters = {
      require('neotest-vitest'),
      require('neotest-jest'),
      require('neotest-elixir'),
    },
  })

  keys.map('n', '<leader>to', function() require('neotest').output.open() end, {
    desc = 'Open test result',
  })
  keys.map('n', '<leader>tS', function() require('neotest').summary.toggle() end, {
    desc = 'Toggle test summary',
  })
  keys.map('n', '<leader>tt', function() require('neotest').run.run() end, {
    desc = 'Run nearest test',
  })
  keys.map('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, {
    desc = 'Run tests in file',
  })
  keys.map('n', '<leader>ts', function() require('neotest').run.stop() end, {
    desc = 'Stop test run',
  })
  keys.map('n', '<leader>tww', function() require('neotest').watch.watch() end, {
    desc = 'Watch nearest test',
  })
  keys.map('n', '<leader>twf', function() require('neotest').watch.watch(vim.fn.expand('%')) end, {
    desc = 'Watch test file',
  })
  keys.map('n', '<leader>tws', function() require('neotest').watch.stop() end, {
    desc = 'Stop watch test',
  })
end)
