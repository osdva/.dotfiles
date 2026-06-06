local deps = require('deps')

-- minuet ai completion
deps.add({
  src = deps.source.gh('milanglacier/minuet-ai.nvim'),
  data = {
    enabled = true,
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
