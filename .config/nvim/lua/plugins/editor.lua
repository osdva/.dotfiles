local deps = require('deps')
local events = require('events')
local keys = require('keymaps')

-- plenary
deps.add({
  src = deps.source.gh('nvim-lua/plenary.nvim'),
  data = {
    dep_of = { 'tiny-code-action.nvim', 'neogit', 'neotest' },
  },
})

-- colorscheme
deps.add({
  src = deps.source.gh('rebelot/kanagawa.nvim'),
  data = {
    colorscheme = 'kanagawa',
    after = function(_)
      require('kanagawa').setup({
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = 'none',
              },
            },
          },
        },
        theme = 'dragon',
        background = {
          dark = 'dragon',
          light = 'lotus',
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            NormalFloat = { bg = 'none' },
            FloatBorder = { fg = theme.ui.bg_p2, bg = 'none' },
            FloatTitle = { bg = 'none' },
            Pmenu = { fg = theme.ui.shade0, bg = 'none' },
            PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
            BlinkCmpMenuBorder = { fg = theme.ui.bg_p2, bg = 'none' },
          }
        end,
      })

      events.autocmd('ColorScheme', {
        pattern = 'kanagawa',
        callback = function()
          if vim.o.background == 'light' then
            vim.fn.system('kitty +kitten themes Kanagawa_light')
          elseif vim.o.background == 'dark' then
            vim.fn.system('kitty +kitten themes Kanagawa_dragon')
          else
            vim.fn.system('kitty +kitten themes Kanagawa')
          end
        end,
      })
    end,
  },
})

vim.cmd('colorscheme kanagawa')

-- mini plugins
deps.add({
  -- icons
  {
    src = deps.source.gh('nvim-mini/mini.icons'),
    data = {
      dep_of = 'oil.nvim',
      after = function(_) require('mini.icons').setup({}) end,
    },
  },
  -- extra
  {
    src = deps.source.gh('nvim-mini/mini.extra'),
    data = {
      after = function(_) require('mini.extra').setup({}) end,
    },
  },
  -- misc
  {
    src = deps.source.gh('nvim-mini/mini.misc'),
    data = {
      after = function(_) require('mini.misc').setup({}) end,
    },
  },
  -- comment
  {
    src = deps.source.gh('nvim-mini/mini.comment'),
    data = {
      after = function(_) require('mini.comment').setup({}) end,
    },
  },
  -- autopairs
  {
    src = deps.source.gh('nvim-mini/mini.pairs'),
    data = {
      after = function(_) require('mini.pairs').setup({}) end,
    },
  },
  -- surround
  {
    src = deps.source.gh('nvim-mini/mini.surround'),
    data = {
      after = function(_) require('mini.surround').setup({}) end,
    },
  },
  -- indentscope
  {
    src = deps.source.gh('nvim-mini/mini.indentscope'),
    data = {
      after = function(_)
        local indentscope = require('mini.indentscope')

        indentscope.setup({
          draw = {
            delay = 100,
            animation = indentscope.gen_animation.none(),
          },
          options = { try_as_border = true },
          symbol = '▎',
        })
      end,
    },
  },
  -- statusline
  {
    src = deps.source.gh('nvim-mini/mini.statusline'),
    data = {
      after = function(_) require('mini.statusline').setup({}) end,
    },
  },
  -- hipatterns
  {
    src = deps.source.gh('nvim-mini/mini.hipatterns'),
    data = {
      after = function(_)
        local hipatterns = require('mini.hipatterns')
        local hi_words = MiniExtra.gen_highlighter.words
        hipatterns.setup({
          highlighters = {
            fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
            hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
            todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
            note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })
      end,
    },
  },
  -- notify
  {
    src = deps.source.gh('nvim-mini/mini.notify'),
    data = {
      after = function(_)
        local max_notifications = 3

        require('mini.notify').setup({
          content = {
            sort = function(notif_arr)
              local sorted = MiniNotify.default_sort(notif_arr)
              local limited = {}

              for i = 1, math.min(max_notifications, #sorted) do
                limited[i] = sorted[i]
              end

              return limited
            end,
          },
          window = { config = { border = 'rounded' }, max_width_share = 0.25 },
        })
        vim.notify = MiniNotify.make_notify()
      end,
    },
  },
})

-- clue
deps.add({
  src = deps.source.gh('nvim-mini/mini.clue'),
  data = {
    after = function(_)
      local miniclue = require('mini.clue')

      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },
          { mode = 'v', keys = '<leader>' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },
        clues = {
          { mode = 'n', keys = '<leader>a', desc = '+ai' },
          { mode = 'n', keys = '<leader>b', desc = '+buffer' },
          { mode = 'n', keys = '<leader>d', desc = '+deps' },
          { mode = 'n', keys = '<leader>f', desc = '+find' },
          { mode = 'n', keys = '<leader>g', desc = '+git' },
          { mode = 'n', keys = '<leader>l', desc = '+lsp' },
          { mode = 'n', keys = '<leader>c', desc = '+code' },
          { mode = 'n', keys = '<leader>t', desc = '+test' },
          { mode = 'n', keys = '<leader>tw', desc = '+test+watch' },
          { mode = 'n', keys = '<leader>s', desc = '+search' },
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
        window = {
          delay = 300,
        },
      })
    end,
  },
})

-- oil
deps.add({
  src = deps.source.gh('stevearc/oil.nvim'),
  data = {
    after = function(_)
      require('oil').setup({
        view_options = {
          show_hidden = true,
        },
        float = {
          max_width = 100,
          max_height = 40,
        },
      })

      keys.map('n', '-', '<CMD>Oil<CR>', { desc = 'File explorer' })
    end,
  },
})

-- pick
deps.add({
  src = deps.source.gh('nvim-mini/mini.pick'),
  data = {
    after = function(_)
      local pick = require('mini.pick')

      pick.setup({
        window = {
          config = function()
            local height, width, starts, ends
            local win_width = vim.o.columns
            local win_height = vim.o.lines

            if win_height <= 25 then
              height = math.min(win_height, 18)
              width = win_width
              starts = 1
              ends = win_height
            else
              width = math.floor(win_width * 0.5)
              height = math.floor(win_height * 0.3)
              starts = math.floor((win_width - width) / 2)
              ends = math.floor(win_height * 0.65)
            end

            return {
              col = starts,
              row = ends,
              height = height,
              width = width,
            }
          end,
        },
      })

      vim.ui.select = pick.ui_select

      keys.map('n', '<leader>ff', '<CMD>Pick files<CR>', { desc = 'Find files' })
      keys.map('n', '<leader>fb', '<CMD>Pick buffers<CR>', { desc = 'Find buffers' })
      keys.map('n', '<leader>fh', '<CMD>Pick help<CR>', { desc = 'Find help pages' })
      keys.map('n', '<leader>fg', '<CMD>Pick grep_live<CR>', { desc = 'Find live grep' })
      keys.map('n', '<leader>fG', '<CMD>Pick grep pattern="<cword>"<CR>', { desc = 'Find grep word' })
      keys.map('n', '<leader>fR', '<CMD>Pick resume<CR>', { desc = 'Find resume' })
    end,
  },
})

-- render markdown
deps.add({
  src = deps.source.gh('MeanderingProgrammer/render-markdown.nvim'),
  data = {
    after = function(_)
      require('render-markdown').setup({
        completions = { lsp = { enabled = true } },
      })
    end,
  },
})

-- replace
deps.add({
  src = deps.source.gh('MagicDuck/grug-far.nvim'),
  data = {
    after = function(_)
      require('grug-far').setup({})

      keys.map('n', '<leader>sr', '<CMD>GrugFar<CR>', { desc = 'Search & Replace' })
    end,
  },
})

-- inline diagnostics
deps.add({
  src = deps.source.gh('rachartier/tiny-inline-diagnostic.nvim'),
  data = {
    after = function(_)
      require('tiny-inline-diagnostic').setup()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
})

-- code action
deps.add({
  src = deps.source.gh('rachartier/tiny-code-action.nvim'),
  data = {
    after = function(_)
      require('tiny-code-action').setup({
        backend = 'vim',
        picker = 'select',
      })
    end,
  },
})
