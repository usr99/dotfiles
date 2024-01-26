--[[
Some of the logic is really dependent on the way treesitter builds its syntax tree
type :InspectTree in a C or C++ file to get a view of the tree for the current buffer
]]

-- Starting from node, find all "identifier" nodes
-- and store their text value in ident_list
local function recursive_ident_search(node, ident_list)
	if not node then
		return
	end

	if node:type() == "identifier" then
		local srow, scol, erow, ecol = node:range()
		local name = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})[1]
		table.insert(ident_list, name)
	end

	for child in node:iter_children() do
		recursive_ident_search(child, ident_list)
	end
end

local generate_doc_fn = function(node)
	local parameters = nil
	for child in node:iter_children() do
		if child:type() == "parameter_list" then
			parameters = child
			break
		end
	end

	print(parameters)

	local ident_list = {}
	recursive_ident_search(parameters, ident_list) 

	local lines = { "/*!", " * \\brief ", " *" }
	for _, param in pairs(ident_list) do
		table.insert(lines, " * \\param[in] " .. param)
	end
	if #ident_list ~= 0 then
		table.insert(lines, " *")
	end
	table.insert(lines, " * \\return ")
	table.insert(lines, " */")

	return lines
end

local generate_doc_struct = function(node)
	local ident_list = {}
	recursive_ident_search(node, ident_list)

	local struct_name = table.remove

	return {
		"\\brief struct"
	}
end

local generate_doc_file = function()
	-- Retrieve the FULL path of the current buffer
	local filename = vim.api.nvim_buf_get_name(0)

	-- Create an iterator over portions of the path
	local path = string.gmatch(filename, "[^%s/]+")

	-- Consume the iterator and store the last element
	for elem in path do
		filename = elem 
	end

	return {
		"/*!",
		" * \\file " .. filename, 
		" */"
	}
end

local map_node_to_genfn = {
	["function_declaration"] = generate_doc_fn,
	["function_definition"]  = generate_doc_fn,
	["struct_specifier"]     = generate_doc_struct,
	["type_definition"]      = generate_doc_struct,
	["translation_unit"]     = generate_doc_file
} 

function MY_NEOGEN()
	-- This feature is intended for C and C++ only
	if vim.bo.filetype ~= 'c' and vim.bo.filetype ~= 'cpp' then
		print('not a C/C++ file')
		return
	end

	-- Find the node to document
	-- climbs the tree until it finds a "documentable" node
	local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
	local generate_doc = map_node_to_genfn[node:type()]
	while generate_doc == nil do
		node = node:parent()
		if not node then
			print('failed to get a valid node to document')
			return
		end
		generate_doc = map_node_to_genfn[node:type()]
	end

	-- Generate documentation based on the node type
	-- node is ignored in case of a file documentation
	local doc = generate_doc(node)

	-- Get the line index before node
	-- treesitter starts indexing lines at 0
	-- therefore we don't need to substract 1 in our case 
	local insert_pos, _, _ = node:start()

	-- Insert the generated documentation above the node
	vim.api.nvim_buf_set_lines(0, insert_pos, insert_pos, _, doc)

	-- Move cursor on inserted text
	-- vim.jump()
end

