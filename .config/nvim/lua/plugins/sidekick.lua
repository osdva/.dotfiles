local deps = require('deps')
local keys = require('keymaps')

-- sidekick
deps.add({
  src = deps.source.gh('folke/sidekick.nvim'),
  data = {
    after = function(_)
      require('sidekick').setup({
        cli = {
          tools = {
            cursor = {},
            pi = {},
          },
        },
      })

      local cli = require('sidekick.cli')

      keys.map({ 'n', 't', 'i', 'x' }, '<C-.>', function()
        cli.focus()
      end, { desc = 'Sidekick focus' })

      keys.map('n', '<leader>aa', function()
        cli.toggle()
      end, { desc = 'Sidekick toggle CLI' })

      keys.map('n', '<leader>as', function()
        cli.select()
      end, { desc = 'Sidekick select CLI' })

      keys.map('n', '<leader>aC', function()
        cli.toggle({ name = 'cursor', focus = true })
      end, { desc = 'Sidekick cursor' })

      keys.map('n', '<leader>aP', function()
        cli.toggle({ name = 'pi', focus = true })
      end, { desc = 'Sidekick pi' })

      keys.map({ 'n', 'x' }, '<leader>at', function()
        cli.send({ msg = '{this}' })
      end, { desc = 'Sidekick send this' })

      keys.map('n', '<leader>af', function()
        cli.send({ msg = '{file}' })
      end, { desc = 'Sidekick send file' })

      keys.map('x', '<leader>av', function()
        cli.send({ msg = '{selection}' })
      end, { desc = 'Sidekick send selection' })

      keys.map({ 'n', 'x' }, '<leader>ap', function()
        cli.prompt()
      end, { desc = 'Sidekick select prompt' })
    end,
  },
})
