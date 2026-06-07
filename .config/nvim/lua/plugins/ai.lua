local deps = require('deps')
local keys = require('keymaps')

-- minuet ai completion
deps.add({
  src = deps.source.gh('milanglacier/minuet-ai.nvim'),
  data = {
    enabled = vim.env.OPENCODE_GO_API_KEY ~= nil and vim.env.OPENCODE_GO_API_KEY ~= '',
    dep_of = 'blink.cmp',
    after = function(_)
      require('minuet').setup({
        provider = 'openai_compatible',
        request_timeout = 5,
        throttle = 1000,
        debounce = 300,
        blink = { enable_auto_complete = true },
        provider_options = {
          openai_compatible = {
            api_key = 'OPENCODE_GO_API_KEY',
            end_point = 'https://opencode.ai/zen/go/v1/chat/completions',
            model = 'deepseek-v4-flash',
            name = 'Opencode',
            optional = {
              max_tokens = 56,
              top_p = 0.9,
              thinking = { type = 'disabled' },
            },
          },
        },
      })
    end,
  },
})

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
