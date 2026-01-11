local deps = require('main.plugins.deps')
local events = require('main.core.events')

-- Formatting
deps.later(function()
  deps.add({ source = 'stevearc/conform.nvim' })

  local conform = require('conform')

  conform.setup({
    default_format_opts = {
      lsp_format = 'fallback',
    },
    format_on_save = { timeout_ms = 1000 },
    formatters_by_ft = {
      lua = { 'stylua' },
      elixir = { 'mix' },
      eelixir = { 'mix' },
      heex = { 'mix' },
      surface = { 'mix' },
      jsonc = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      json = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      sh = { 'shellcheck', 'shfmt' },
      fish = { 'fish_indent', 'fish-lsp' },
      kdl = { 'kdlfmt' },
    },
    formatters = {
      biome = {
        command = 'biome',
        args = {
          'format',
          '--stdin-file-path',
          '$FILENAME',
          '--format-with-errors=true',
        },
        stdin = true,
        cwd = require('conform.util').root_file({ 'biome.json' }),
      },
      prettier = {
        command = 'prettier',
        args = {
          '--stdin-filepath',
          '$FILENAME',
          '--parser',
          'json',
        },
        stdin = true,
      },
    },
  })

  vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function(args)
      conform.format({
        bufnr = args.buf,
        lsp_format = 'fallback',
      })
    end,
  })
end)

-- Linting
deps.later(function()
  deps.add({ source = 'mfussenegger/nvim-lint' })

  local lint = require('lint')

  lint.linters_by_ft = {
    javascript = { 'biomejs', 'eslint_d' },
    javascriptreact = { 'biomejs', 'eslint_d' },
    typescript = { 'biomejs', 'eslint_d' },
    typescriptreact = { 'biomejs', 'eslint_d' },
    jsonc = { 'biomejs', 'eslint_d' },
    json = { 'biomejs', 'eslint_d' },
  }

  local lint_augroup = events.augroup('lint', { clear = true })

  events.autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function() lint.try_lint() end,
  })
end)
