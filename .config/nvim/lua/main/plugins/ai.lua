local deps = require('main.plugins.deps')
local keys = require('main.core.keymaps')

deps.later(function()
  deps.add({
    source = 'greggh/claude-code.nvim',
    depends = { 'nvim-lua/plenary.nvim' },
  })

  require('claude-code').setup({
    keymaps = {
      toggle = {
        normal = '<leader>acc',
        terminal = false,
      },
    },
  })
end)

deps.later(function()
  deps.add({ source = 'nickjvandyke/opencode.nvim' })

  keys.map({ 'n', 't' }, '<leader>aoc', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
end)
