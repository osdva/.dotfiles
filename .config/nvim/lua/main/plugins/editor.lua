local deps = require('main.plugins.deps')
local keys = require('main.core.keymaps')
local events = require('main.core.events')

-- colorscheme
deps.now(function()
  deps.add({
    source = 'rebelot/kanagawa.nvim',
  })

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

  vim.cmd('colorscheme kanagawa')
end)

-- icons
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.icons',
  })
  require('mini.icons').setup()
end)

-- extra
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.extra',
  })

  require('mini.extra').setup({})
end)

-- misc
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.misc',
  })

  require('mini.misc').setup({})
end)

-- comment
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.comment',
  })

  require('mini.comment').setup({})
end)

-- autopairs
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.pairs',
  })

  require('mini.pairs').setup({})
end)

-- notify
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.notify',
  })
  require('mini.notify').setup({
    window = { config = { border = 'rounded' } },
  })
  vim.notify = MiniNotify.make_notify()
end)

-- patterns
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.hipatterns',
  })

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
end)

-- statusline
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.statusline',
  })

  require('mini.statusline').setup({})
end)

-- starter
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.starter',
  })

  local starter = require('mini.starter')

  starter.setup({
    header = "sdvauos' nvim",
    items = {
      starter.sections.sessions(5),
      starter.sections.recent_files(5, false),
      starter.sections.builtin_actions(),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.aligning('center', 'top'),
      starter.gen_hook.padding(3, 5),
    },
  })
end)

-- clue
deps.now(function()
  deps.add({
    source = 'nvim-mini/mini.clue',
  })

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
      { mode = 'n', keys = '<leader>b', desc = '+buffer' },
      { mode = 'n', keys = '<leader>d', desc = '+deps' },
      { mode = 'n', keys = '<leader>f', desc = '+find' },
      { mode = 'n', keys = '<leader>g', desc = '+git' },
      { mode = 'n', keys = '<leader>l', desc = '+lsp' },
      { mode = 'n', keys = '<leader>lc', desc = '+lsp+code_actions' },
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
end)

-- Explorer
deps.now(function()
  deps.add({
    source = 'stevearc/oil.nvim',
    depends = {
      'nvim-mini/mini.icons',
    },
  })

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
end)

-- pick
deps.now(function()
  deps.add({ source = 'nvim-mini/mini.pick' })

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

  -- local custom_pickers = require('main.plugins.pickers')
  -- local pickers = vim.tbl_extend('force', custom_pickers, pick.builtin)
  -- pick.registry = pickers

  vim.ui.select = MiniPick.ui_select

  keys.map('n', '<leader>ff', '<CMD>:Pick files<CR>', { desc = 'Find files' })
  keys.map('n', '<leader>fb', '<CMD>:Pick buffers<CR>', { desc = 'Find buffers' })
  keys.map('n', '<leader>fh', '<CMD>:Pick help<CR>', { desc = 'Find help pages' })
  keys.map('n', '<leader>fg', '<CMD>:Pick grep_live<CR>', { desc = 'Find live grep' })
  keys.map('n', '<leader>fG', '<CMD>:Pick grep pattern="<cword>"<CR>', { desc = 'Find grep word' })
  keys.map('n', '<leader>fR', '<CMD>:Pick resume<CR>', { desc = 'Find resume' })
end)

-- code action
deps.now(function()
  deps.add({ source = 'rachartier/tiny-code-action.nvim', depends = { 'nvim-lua/plenary.nvim' } })

  require('tiny-code-action').setup({
    backend = 'vim',
    picker = 'select',
  })
end)

-- inline diagnostics
deps.now(function()
  deps.add({ source = 'rachartier/tiny-inline-diagnostic.nvim' })

  require('tiny-inline-diagnostic').setup()
  vim.diagnostic.config({ virtual_text = false })
end)

-- buffer
deps.now(function()
  deps.add({ source = 'nvim-mini/mini.visits' })

  require('mini.visits').setup({})

  -- local fzf = require('main.plugins.fzf')

  keys.map('n', '<leader>ba', '<CMD>:lua MiniVisits.add_label("core")<CR>', { desc = 'Add file to core' })
  keys.map('n', '<leader>br', '<CMD>:lua MiniVisits.remove_label("core")<CR>', { desc = 'Remove file from core' })
  keys.map('n', '[[', function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    MiniVisits.iterate_paths('forward', vim.fn.getcwd(), { filter = 'core', sort = sort_latest, wrap = true })
  end, { desc = 'Next file in core' })
  keys.map('n', ']]', function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    MiniVisits.iterate_paths('backward', vim.fn.getcwd(), { filter = 'core', sort = sort_latest, wrap = true })
  end, { desc = 'Previous file in core' })
  keys.map('n', '<leader>bA', '<CMD>:lua MiniVisits.add_label()<CR>', { desc = 'Add file to label' })
  keys.map('n', '<leader>bR', '<CMD>:lua MiniVisits.remove_label()<CR>', { desc = 'Remove file from label' })
  keys.map(
    'n',
    '<leader>bb',
    '<CMD>:lua MiniVisits.select_path(nil, { filter = "core" })<CR>',
    { desc = 'Select all paths in core' }
  )
  -- keys.map('n', '<leader>bf', fzf.pick_visits_labels, { desc = 'Find labels' })
end)

-- surround
deps.now(function()
  deps.add({ source = 'nvim-mini/mini.surround' })

  require('mini.surround').setup({})
end)

-- indent scope
deps.now(function()
  deps.add({ source = 'nvim-mini/mini.indentscope' })

  require('mini.indentscope').setup({
    draw = {
      delay = 100,
      animation = require('mini.indentscope').gen_animation.none(),
    },
    options = { try_as_border = true },
    symbol = '▎',
  })
end)

-- render markdown
deps.later(function()
  deps.add({ source = 'MeanderingProgrammer/render-markdown.nvim' })
  require('render-markdown').setup({
    completions = { lsp = { enabled = true } },
  })
end)

-- replace
deps.now(function()
  deps.add({ source = 'MagicDuck/grug-far.nvim' })

  require('grug-far').setup({})

  keys.map('n', '<leader>sr', '<CMD>GrugFar<CR>', { desc = 'Search & Replace' })
end)
