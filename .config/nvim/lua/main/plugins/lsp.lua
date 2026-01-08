local deps = require('main.plugins.deps')
local events = require('main.core.events')
local keys = require('main.core.keymaps')

-- installer
deps.later(function()
  deps.add({ source = 'mason-org/mason.nvim' })
  require('mason').setup({
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  })
end)

-- cmp
deps.later(function()
  deps.add({
    source = 'saghen/blink.cmp',
    depends = { 'fang2hou/blink-copilot', 'rafamadriz/friendly-snippets', 'L3MON4D3/LuaSnip' },
    monitor = 'main',
    checkout = 'v1.6.0',
  })

  require('blink.cmp').setup({
    keymap = { preset = 'default' },
    appearance = {
      nerd_font_variant = 'mono',
      kind_icons = {
        Copilot = '',
        Text = '󰉿',
        Method = '󰊕',
        Function = '󰊕',
        Constructor = '󰒓',

        Field = '󰜢',
        Variable = '󰆦',
        Property = '󰖷',

        Class = '󱡠',
        Interface = '󱡠',
        Struct = '󱡠',
        Module = '󰅩',

        Unit = '󰪚',
        Value = '󰦨',
        Enum = '󰦨',
        EnumMember = '󰦨',

        Keyword = '󰻾',
        Constant = '󰏿',

        Snippet = '󱄽',
        Color = '󰏘',
        File = '󰈔',
        Reference = '󰬲',
        Folder = '󰉋',
        Event = '󱐋',
        Operator = '󰪚',
        TypeParameter = '󰬛',
      },
    },
    completion = {
      keyword = { range = 'full' },
      list = { selection = { auto_insert = false } },
      menu = { border = 'rounded' },
      documentation = { auto_show = true, auto_show_delay_ms = 100, window = { border = 'rounded' } },
    },
    signature = { enabled = true, window = { border = 'rounded' } },
    snippets = {
      preset = 'luasnip',
    },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },
  })
end)

-- lsp
deps.later(function()
  deps.add({ source = 'neovim/nvim-lspconfig' })
  deps.add({
    source = 'WhoIsSethDaniel/mason-tool-installer.nvim',
    depends = { 'mason-org/mason.nvim' },
  })

  -- LSP server configurations
  local lsp_configs = {
    {
      name = 'lua_ls',
      root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    },
    {
      name = 'cssls',
      root_markers = { 'package.json', '.git' },
    },
    {
      name = 'tailwindcss',
      root_markers = { 'tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', '.git' },
    },
    {
      name = 'expert',
      cmd = { 'expert', '--stdio' },
      filetypes = { 'elixir', 'eelixir', 'heex' },
      root_markers = { 'mix.exs', '.git' },
    },
    {
      name = 'ts_ls',
      root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    },
    {
      name = 'vue_ls',
      root_markers = { 'package.json', '.git' },
    },
  }

  -- Non-LSP tools (formatters, linters)
  local formatters_linters = {
    'stylua',
    'eslint_d',
    'prettierd',
    'prettier',
    'biome',
  }

  local lsp_server_names = {}
  for _, config in ipairs(lsp_configs) do
    table.insert(lsp_server_names, config.name)
  end

  for _, config in ipairs(lsp_configs) do
    local name = config.name

    local has_lspconfig, lspconfig_mod = pcall(require, 'lspconfig.server_configurations.' .. name)
    local defaults = has_lspconfig and lspconfig_mod.default_config or {}

    local cfg = vim.tbl_deep_extend('force', {}, defaults, config)
    cfg.name = nil

    vim.lsp.config(name, cfg)
  end

  local ensure_installed = vim.list_extend(vim.list_slice(lsp_server_names), formatters_linters)
  require('mason-tool-installer').setup({
    ensure_installed = ensure_installed,
  })

  vim.lsp.enable(lsp_server_names)

  vim.diagnostic.config({
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
      },
    },
  })

  events.autocmd('LspAttach', {
    callback = function(args)
      local bufnr = args.buf

      keys.map(
        'n',
        '<leader>ld',
        '<CMD>:Pick lsp scope="definition"<CR>',
        { buffer = bufnr, desc = 'Find definitions' }
      )
      keys.map('n', '<leader>lr', '<CMD>:Pick lsp scope="references"<CR>', { buffer = bufnr, desc = 'Find references' })
      keys.map('n', '<leader>lh', '<CMD>:lua vim.lsp.buf.hover()<CR>', {
        buffer = bufnr,
        desc = 'Show hover information',
      })
      keys.map('n', '<leader>ll', '<CMD>:lua vim.diagnostic.open_float(0, { scope = "line" })<CR>', {
        buffer = bufnr,
        desc = 'Show line diagnostics',
      })
      keys.map('n', '<leader>lcr', '<CMD>:lua vim.lsp.buf.rename()<CR>', { buffer = bufnr, desc = 'Rename symbol' })
      keys.map({ 'n', 'x' }, '<leader>lca', '<CMD>:lua require("tiny-code-action").code_action()<CR>', {
        buffer = bufnr,
        desc = 'Code actions',
      })
    end,
  })
end)

-- lazydev
deps.later(function()
  deps.add({ source = 'folke/lazydev.nvim', depends = { 'saghen/blink.cmp' } })

  require('lazydev').setup({
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  })
end)
