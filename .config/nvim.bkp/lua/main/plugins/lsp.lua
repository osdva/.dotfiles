local deps = require('main.plugins.deps')
local events = require('main.core.events')
local keys = require('main.core.keymaps')

-- installer
deps.now(function()
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

  -- Single source of truth for LSP + Mason package mapping
  local lsp_registry = {
    lua_ls = {
      mason = 'lua-language-server',
      config = {},
    },
    cssls = {
      mason = 'css-lsp',
      config = {},
    },
    tailwindcss = {
      mason = 'tailwindcss-language-server',
      config = {},
    },
    expert = {
      mason = 'expert',
      config = {},
    },
    ts_ls = {
      mason = 'typescript-language-server',
      config = {},
    },
    astro_ls = {
      mason = 'astro-language-server',
      config = {},
    },
    fish_lsp = {
      mason = 'fish-lsp',
      config = {},
    },
    jq_lsp = {
      mason = 'jq-lsp',
      config = {},
    },
    harper_ls = {
      mason = 'harper-ls',
      config = {
        settings = {
          ['harper-ls'] = {
            userDictPath = '',
            workspaceDictPath = '',
            fileDictPath = '',
            linters = {
              SpellCheck = false,
              SpelledNumbers = false,
              AnA = true,
              SentenceCapitalization = false,
              UnclosedQuotes = true,
              WrongQuotes = false,
              LongSentences = true,
              RepeatedWords = true,
              Spaces = true,
              Matcher = true,
              CorrectNumberSuffix = true,
            },
            codeActions = {
              ForceStable = false,
            },
            markdown = {
              IgnoreLinkTitle = false,
            },
            diagnosticSeverity = 'hint',
            isolateEnglish = false,
            dialect = 'American',
            maxFileLength = 120000,
            ignoredLintsPath = '',
            excludePatterns = {},
          },
        },
      },
    },
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

  local enabled_servers = {}
  local ensure_installed = vim.list_slice(non_lsp_tools)

  for name, spec in pairs(lsp_registry) do
    vim.lsp.config(name, spec.config or {})
    table.insert(enabled_servers, name)
    if spec.mason then table.insert(ensure_installed, spec.mason) end
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
