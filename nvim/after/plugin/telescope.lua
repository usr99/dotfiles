local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
vim.keymap.set('n', '<leader>ts', builtin.treesitter, {})

-- Helper to define LSP mappings
local map = function(keys, func, desc)
	vim.keymap.set('n', keys, func, { desc = 'LSP: ' .. desc })
end

-- Show LSP info on hovered symbol
-- vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover)
map('<leader>h', vim.lsp.buf.hover, '[H]elp')

-- Jump to the definition of the word under your cursor.
--  This is where a variable was first declared, or where a function is defined, etc.
--  To jump back, press <C-t>.
map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

-- Find references for the word under your cursor.
map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

-- Jump to the implementation of the word under your cursor.
--  Useful when your language has ways of declaring types without an actual implementation.
map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

-- Jump to the type of the word under your cursor.
--  Useful when you're not sure what type a variable is and you want to see
--  the definition of its *type*, not where it was *defined*.
map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

-- Fuzzy find all the symbols in your current document.
--  Symbols are things like variables, functions, types, etc.
map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

-- Fuzzy find all the symbols in your current workspace.
--  Similar to document symbols, except searches over your entire project.
map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

-- Execute a code action, usually your cursor needs to be on top of an error
-- or a suggestion from your LSP for this to activate.
map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

