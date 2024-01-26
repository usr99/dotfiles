require('custom.set')
require('custom.mappings')
-- require('custom.neogen')

-- Beautiful colorscheme
vim.cmd.colorscheme('onedark')

-- Disable diagnostics on the screen
-- useful for huge projects and include paths mayhem
vim.diagnostic.disable()

-- List of highlight groups to set background as transparent
bg_groups = {
	'Normal', 'Comment', 'NormalNC', 'Constant', 'Special', 'Identifier',
	'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
	'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
	'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
	'EndOfBuffer',
}
for _,hl in ipairs(bg_groups) do
	vim.api.nvim_set_hl(0, hl, { bg="none", ctermbg="none" })
end

-- List of highlight groups to set as grey (white by default)
fg_groups = {
	'SignColumn', 'LineNr', 'Comment',
}
for _,hl in ipairs(fg_groups) do
	vim.api.nvim_set_hl(0, hl, { fg="grey" })
end

