local deps = require('deps')
local events = require('events')

-- formatting
deps.add({
  src = deps.source.gh('stevearc/conform.nvim'),
  data = {
    after = function(_)
      require('conform').setup({
        default_format_opts = {
          lsp_format = 'fallback',
        },
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          elixir = { 'mix' },
          eelixir = { 'mix' },
          heex = { 'mix' },
          surface = { 'mix' },
          jsonc = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          json = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          javascript = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          javascriptreact = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          typescript = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          astro = { 'prettierd', 'prettier', 'biome', stop_after_first = true },
          sh = { 'shellcheck', 'shfmt' },
          bash = { 'shellcheck', 'shfmt' },
          zsh = { 'shellcheck', 'shfmt' },
          fish = { 'fish_indent' },
          kdl = { 'kdlfmt' },
        },
        formatters = {
          mix = {
            command = 'mix',
            args = { 'format', '-' },
            cwd = require('conform.util').root_file({ 'mix.exs' }),
          },
        },
      })
    end,
  },
})

-- linting
deps.add({
  src = deps.source.gh('mfussenegger/nvim-lint'),
  data = {
    after = function(_)
      local lint = require('lint')

      lint.linters_by_ft = {
        astro = { 'biomejs' },
        javascript = { 'biomejs', 'eslint_d' },
        javascriptreact = { 'biomejs', 'eslint_d' },
        typescript = { 'biomejs', 'eslint_d' },
        typescriptreact = { 'biomejs', 'eslint_d' },
        jsonc = { 'biomejs' },
        json = { 'biomejs' },
        sh = { 'shellcheck' },
        bash = { 'shellcheck' },
        zsh = { 'shellcheck' },
        fish = { 'fish' },
      }

      local lint_augroup = events.augroup('lint', { clear = true })

      events.autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function() lint.try_lint() end,
      })
    end,
  },
})
