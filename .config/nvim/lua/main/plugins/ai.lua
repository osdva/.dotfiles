local deps = require('main.plugins.deps')
local keys = require('main.core.keymaps')

deps.later(function()
  deps.add({
    source = 'zbirenbaum/copilot.lua',
    hooks = { post_install = function() vim.cmd('Copilot') end },
  })
  require('copilot').setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
end)

deps.later(function()
  deps.add({ source = 'copilotlsp-nvim/copilot-lsp' })

  require('copilot-lsp').setup({
    nes = {
      move_count_threshold = 3,
    },
  })

  vim.g.copilot_nes_debounce = 250
  vim.lsp.enable('copilot_ls')

  vim.keymap.set('n', '<tab>', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local state = vim.b[bufnr].nes_state
    if state then
      local _ = require('copilot-lsp.nes').walk_cursor_start_edit()
        or (require('copilot-lsp.nes').apply_pending_nes() and require('copilot-lsp.nes').walk_cursor_end_edit())
      return nil
    else
      return '<C-i>'
    end
  end, { desc = 'Accept Copilot NES suggestion', expr = true })
end)

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
