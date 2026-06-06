local M = {}

M.autocmd = vim.api.nvim_create_autocmd
M.user_cmd = vim.api.nvim_create_user_command
M.augroup = vim.api.nvim_create_augroup

return M
