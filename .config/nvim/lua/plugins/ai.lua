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

-- copilot
deps.add({
  src = deps.source.gh('zbirenbaum/copilot.lua'),
  data = {
    enabled = true,
    dep_of = { 'blink-copilot', 'copilot-lsp' },
    after = function(_)
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
})

-- copilot next edit suggestions
deps.add({
  src = deps.source.gh('copilotlsp-nvim/copilot-lsp'),
  data = {
    enabled = true,
    after = function(_)
      require('copilot-lsp').setup({
        nes = {
          move_count_threshold = 3,
          distance_threshold = 40,
          clear_on_large_distance = true,
          count_horizontal_moves = true,
          reset_on_approaching = true,
        },
      })

      vim.g.copilot_nes_debounce = 250
      vim.lsp.enable('copilot_ls')

      vim.keymap.set('n', '<Tab>', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local state = vim.b[bufnr].nes_state

        if state then
          local nes = require('copilot-lsp.nes')
          local _ = nes.walk_cursor_start_edit() or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
          return nil
        end

        return '<C-i>'
      end, { desc = 'Accept Copilot NES suggestion', expr = true })
    end,
  },
})
