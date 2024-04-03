vim.g.mapleader = " "

-- Install lazy if not already
local lazypath = vim.fn.stdpath("data") .. "lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath
	})
end
vim.opt.rtp:prepend(lazypath)

-- Install my favorites plugins
require('lazy').setup({
	-- tmux / vim integration
	"christoomey/vim-tmux-navigator",
	-- Fun plugins
	"eandrju/cellular-automaton.nvim", -- run a cellular automaton from the content of the buffer
	-- Themes
	 { "rose-pine/neovim", name = "rose-pine" },
	"folke/tokyonight.nvim",
	"olimorris/onedarkpro.nvim",
	"nanotech/jellybeans.vim",
	"savq/melange-nvim",
	"ellisonleao/gruvbox.nvim",
	"NLKNguyen/papercolor-theme",
	"olivercederborg/poimandres.nvim",
	"AlexvZyl/nordic.nvim",
	-- Fuzzy Finder
	{
		"nvim-telescope/telescope.nvim",
		tag = '0.1.5',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	-- Toggle comment lines and blocks
	{
		"numToStr/Comment.nvim",
		config = function()
			require('Comment').setup()
		end
	},
	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate"
	},
	-- Automatically close parenthesis, brackets and quotes
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {}
	},
	-- Git management
	"tpope/vim-fugitive",
	-- Language Server Protocol
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = 'v3.x',
		lazy = true,
		config = false
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
		}
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
		}
	},
	{ "hrsh7th/cmp-buffer", name = "buffer" },
	{ "hrsh7th/cmp-path",   name = "path" },
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"nvim-lualine/lualine.nvim",
	"lewis6991/gitsigns.nvim",
	{
		"rust-lang/rust.vim",
		ft = "rust",
		init = function ()
			-- vim.g.rustfmt_autosave = 1
			vim.g.rust_recommended_style = false
		end
	},
	{
		"folke/twilight.nvim",
		opts = {
			dimming = {
				alpha = 0.50
			},
			context = 20
		}
	},
	"xiyaowong/transparent.nvim",
	"nvim-treesitter/playground",
	{
		"vimpostor/vim-tpipeline",
		init = function ()
			vim.g.tpipeline_restore = 1
		end
	}
})

-- Import my custom config, mostly keybinds
require('custom')
