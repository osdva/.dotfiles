local deps = require('deps')
local events = require('events')
local keys = require('keymaps')

-- installer
deps.add({
  src = deps.source.gh('mason-org/mason.nvim'),
  data = {
    after = function(_)
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      })
    end,
  },
})

-- completion dependencies
deps.add({
  {
    src = deps.source.gh('rafamadriz/friendly-snippets'),
    data = {
      dep_of = 'blink.cmp',
    },
  },
  {
    src = deps.source.gh('L3MON4D3/LuaSnip'),
    data = {
      dep_of = 'blink.cmp',
    },
  },
  {
    src = deps.source.gh('folke/lazydev.nvim'),
    data = {
      dep_of = 'blink.cmp',
      after = function(_)
        require('lazydev').setup({
          library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        })
      end,
    },
  },
  {
    src = deps.source.gh('fang2hou/blink-copilot'),
    data = {
      enabled = true,
      dep_of = 'blink.cmp',
    },
  },
})

-- cmp
deps.add({
  src = deps.source.gh('saghen/blink.cmp'),
  version = 'v1.6.0',
  data = {
    after = function(_)
      require('blink.cmp').setup({
        keymap = {
          preset = 'default',
        },
        appearance = {
          nerd_font_variant = 'mono',
          kind_icons = {
            AI = '󰚩',
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
          trigger = { prefetch_on_insert = false },
        },
        signature = { enabled = true, window = { border = 'rounded' } },
        snippets = {
          preset = 'luasnip',
        },
        sources = {
          default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'copilot', 'minuet' },
          providers = {
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
              score_offset = 100,
            },
            copilot = {
              enabled = true,
              name = 'copilot',
              module = 'blink-copilot',
              score_offset = 100,
              async = true,
            },
            minuet = {
              enabled = true,
              name = 'minuet',
              module = 'minuet.blink',
              score_offset = 100,
              async = true,
              timeout_ms = 5000,
              min_keyword_length = 0,
              transform_items = function(_, items)
                for _, item in ipairs(items) do
                  item.kind_name = 'AI'
                end
                return items
              end,
            },
          },
        },
      })
    end,
  },
})

-- lsp
deps.add({
  {
    src = deps.source.gh('neovim/nvim-lspconfig'),
  },
  {
    src = deps.source.gh('WhoIsSethDaniel/mason-tool-installer.nvim'),
    data = {
      dep_of = 'nvim-lspconfig',
    },
  },
})

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

local lsp_servers = {
  lua_ls = 'lua-language-server',
  cssls = 'css-lsp',
  tailwindcss = 'tailwindcss-language-server',
  expert = 'expert',
  ts_ls = 'typescript-language-server',
  astro = 'astro-language-server',
  fish_lsp = 'fish-lsp',
  jqls = 'jq-lsp',
  harper_ls = 'harper-ls',
}

local non_lsp_tools = {
  'stylua',
  'eslint_d',
  'prettierd',
  'prettier',
  'biome',
  'jq',
  'kdlfmt',
  'shellcheck',
  'shfmt',
  'superhtml',
}

local enabled_servers = vim.tbl_keys(lsp_servers)
local ensure_installed = vim.list_slice(non_lsp_tools)

for _, mason_package in pairs(lsp_servers) do
  table.insert(ensure_installed, mason_package)
end

require('mason-tool-installer').setup({
  ensure_installed = ensure_installed,
})

vim.lsp.enable(enabled_servers)

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

    keys.map('n', '<leader>ld', '<CMD>Pick lsp scope="definition"<CR>', { buffer = bufnr, desc = 'Find definitions' })
    keys.map('n', '<leader>lr', '<CMD>Pick lsp scope="references"<CR>', { buffer = bufnr, desc = 'Find references' })
    keys.map('n', '<leader>lh', function() vim.lsp.buf.hover() end, { buffer = bufnr, desc = 'Show hover information' })
    keys.map(
      'n',
      '<leader>ll',
      function() vim.diagnostic.open_float(0, { scope = 'line' }) end,
      { buffer = bufnr, desc = 'Show line diagnostics' }
    )
    keys.map('n', '<leader>lcr', function() vim.lsp.buf.rename() end, { buffer = bufnr, desc = 'Rename symbol' })
    keys.map(
      { 'n', 'x' },
      '<leader>ca',
      function() require('tiny-code-action').code_action() end,
      { buffer = bufnr, desc = 'Code actions' }
    )
  end,
})
