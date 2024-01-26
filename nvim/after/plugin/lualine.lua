local function statusline()
	local ts = require('nvim-treesitter');
	return ts.statusline()
end

require('lualine').setup({
	options = {
		theme = 'onedark'
	},
	sections = {
		lualine_c = { 'filename', statusline }
	}
})

