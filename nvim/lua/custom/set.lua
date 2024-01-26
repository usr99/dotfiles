vim.opt.guicursor = "" -- Keep block cursor in insert mode

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.smartindent = true
vim.opt.breakindent = true

vim.opt.wrap = false

-- vim.opt.swapfile = true 
-- vim.opt.backup = true
-- vim.opt.undodir = os.getenv("HOME") .. "/.vin/undodir"
-- vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8 -- Reserve 8 lines above the cursor
vim.opt.signcolumn = "yes"

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.opt.listchars = { lead = '·', tab = '│ ' }
vim.opt.list = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
-- vim.o.completeopt = 'menuone, noselect'

