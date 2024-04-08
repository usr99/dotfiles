require('custom.set')
require('custom.mappings')
require('custom.neogen')

-- Beautiful colorscheme
vim.cmd.colorscheme('onedark')

-- Disable diagnostics on the screen
-- useful for huge projects and include paths mayhem
vim.diagnostic.disable()

vim.keymap.set("n", "<leader>nf", MY_NEOGEN)

