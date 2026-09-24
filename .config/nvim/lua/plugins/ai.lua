local deps = require('deps')
local keys = require('keymaps')

-- sidekick
deps.add({
  src = deps.source.gh('folke/sidekick.nvim'),
  data = {
    after = function(_)
      local haunt_sk = require('haunt.sidekick')

      require('sidekick').setup({
        cli = {
          prompts = {
            haunt_all = function() return haunt_sk.get_locations() end,
            haunt_buffer = function() return haunt_sk.get_locations({ current_buffer = true }) end,
          },
          tools = {
            cursor = {},
            pi = {},
          },
        },
      })

      local cli = require('sidekick.cli')

      keys.map({ 'n', 't', 'i', 'x' }, '<C-.>', function() cli.focus() end, { desc = 'Sidekick focus' })

      keys.map('n', '<leader>ai', function() cli.toggle() end, { desc = 'AI toggle' })

      keys.map({ 'n', 'x' }, '<leader>at', function() cli.send({ msg = '{this}' }) end, { desc = 'Sidekick send this' })

      keys.map('n', '<leader>af', function() cli.send({ msg = '{file}' }) end, { desc = 'Sidekick send file' })

      keys.map(
        'x',
        '<leader>av',
        function() cli.send({ msg = '{selection}' }) end,
        { desc = 'Sidekick send selection' }
      )

      keys.map({ 'n', 'x' }, '<leader>ap', function() cli.prompt() end, { desc = 'Sidekick select prompt' })
    end,
  },
})
