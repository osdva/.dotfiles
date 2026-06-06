local keys = require('main.core.keymaps')

local M = {}

local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.deps'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.deps`" | redraw')
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/nvim-mini/mini.deps',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.deps | helptags ALL')
  vim.cmd('echo "Installed `mini.deps`" | redraw')
end

require('mini.deps').setup({ path = { package = path_package } })

M.add = MiniDeps.add
M.now = MiniDeps.now
M.later = MiniDeps.later

M.now(function() MiniDeps.snap_load() end)

keys.map('n', '<leader>di', function()
  MiniDeps.update()
  MiniDeps.snap_save()
end, { desc = 'Install dependencies' })

keys.map('n', '<leader>dc', function()
  MiniDeps.clean()
  MiniDeps.snap_save()
end, { desc = 'Clean dependencies' })

return M
