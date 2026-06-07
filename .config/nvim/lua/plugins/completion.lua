local deps = require('deps')

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
      after = function(_)
        if vim.g.luasnip_snippets_loaded then return end

        vim.g.luasnip_snippets_loaded = true

        local snippet_paths = {}
        for _, plugin in ipairs(vim.pack.get()) do
          if plugin.spec.name == 'friendly-snippets' then table.insert(snippet_paths, plugin.path) end
        end

        require('luasnip.loaders.from_vscode').lazy_load({ paths = snippet_paths })
      end,
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
          default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
          providers = {
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
              score_offset = 100,
            },
            minuet = {
              enabled = vim.env.OPENCODE_GO_API_KEY ~= nil and vim.env.OPENCODE_GO_API_KEY ~= '',
              name = 'minuet',
              module = 'minuet.blink',
              score_offset = 100,
              async = true,
              timeout_ms = 5000,
              min_keyword_length = 2,
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
