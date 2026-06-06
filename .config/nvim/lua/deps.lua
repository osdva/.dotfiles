local keys = require('keymaps')

local M = {}

M.source = {
  gh = function(pkg) return 'https://github.com/' .. pkg end,
}

vim.pack.add({ M.source.gh('BirdeeHub/lze') }, {
  confirm = false,
})

M.add = function(t)
  vim.pack.add(vim.islist(t) and t or { t }, {
    load = function(p)
      local spec = p.spec.data or {}
      spec.name = p.spec.name
      require('lze').load(spec)
    end,
    confirm = true,
  })
end

keys.map('n', '<leader>dd', function() vim.pack.update() end)

return M
