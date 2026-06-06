local M = {}

M.map = vim.keymap.set

M.map('n', '<leader>o', ':update<CR> :source<CR>', { desc = 'Update and source' })
M.map('n', '<leader>w', ':write<CR>', { desc = 'Save' })
M.map('n', '<leader>q', ':quit<CR>', { desc = 'Quit' })

local function close_floating()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == 'win' then vim.api.nvim_win_close(win, false) end
  end
end

M.map('n', '<esc>', function()
  vim.cmd('noh')
  close_floating()
end, { silent = true, desc = 'Remove search highlighting, dismiss popups' })

-- Text manipulation
M.map('n', '<A-j>', ':m .+1<CR>==', { silent = true, noremap = true, desc = 'Move line down' })
M.map('n', '<A-k>', ':m .-2<CR>==', { silent = true, noremap = true, desc = 'Move line up' })
M.map('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move selection down' })
M.map('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move selection up' })
M.map('x', 'J', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block down' })
M.map('x', 'K', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block up' })
M.map('x', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block down' })
M.map('x', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block up' })
M.map('v', 'p', '"_dP', { silent = true, noremap = true, desc = 'Paste without replacing selection' })
M.map('v', '<', '<gv^', { silent = true, noremap = true, desc = 'Shift selection left' })
M.map('v', '>', '>gv^', { silent = true, noremap = true, desc = 'Shift selection right' })

-- Window navigation/resizing
M.map('n', '<C-h>', '<C-w>h', { silent = true, desc = 'Move to left window' })
M.map('n', '<C-j>', '<C-w>j', { silent = true, desc = 'Move to lower window' })
M.map('n', '<C-k>', '<C-w>k', { silent = true, desc = 'Move to upper window' })
M.map('n', '<C-l>', '<C-w>l', { silent = true, desc = 'Move to right window' })

M.map('t', '<C-h>', '<C-\\><C-n><C-w>h', { silent = true, desc = 'Move to left window' })
M.map('t', '<C-j>', '<C-\\><C-n><C-w>j', { silent = true, desc = 'Move to lower window' })
M.map('t', '<C-k>', '<C-\\><C-n><C-w>k', { silent = true, desc = 'Move to upper window' })
M.map('t', '<C-l>', '<C-\\><C-n><C-w>l', { silent = true, desc = 'Move to right window' })

M.map('n', '<A-H>', '<cmd>vertical resize -2<CR>', { silent = true, desc = 'Decrease window width' })
M.map('n', '<A-L>', '<cmd>vertical resize +2<CR>', { silent = true, desc = 'Increase window width' })
M.map('n', '<A-J>', '<cmd>resize -2<CR>', { silent = true, desc = 'Decrease window height' })
M.map('n', '<A-K>', '<cmd>resize +2<CR>', { silent = true, desc = 'Increase window height' })

return M
