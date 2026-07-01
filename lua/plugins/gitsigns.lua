-- Gitsigns
require('gitsigns').setup({
	-- signs = {
	-- 	add          = { text = '+' },
	-- 	change       = { text = '~' },
	-- 	delete       = { text = '_' },
	-- 	topdelete    = { text = '‾' },
	-- 	changedelete = { text = '~' },
	-- },
	current_line_blame = true, -- Set to true to show blame inline
	current_line_blame_opts = {
		-- ignore_whitespace = true, -- This option specifically enables ignoring whitespace for current line blame
	},
})
