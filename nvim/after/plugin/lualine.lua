local function statusline()
	local ts = require('nvim-treesitter');
	return ts.statusline()
end

require('lualine').setup({
	options = {
		globalstatus = true,
		icons_enable = true,
		theme = 'onedark'
	},
	sections = {
		lualine_c = { 'filename', statusline }
	}
})

