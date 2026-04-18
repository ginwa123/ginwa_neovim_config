-- Symbol usage
require('symbol-usage').setup({
	vt_position = 'above', -- Show above the symbol: 'above' | 'end_of_line' | 'textwidth'

	references = {
		enabled = true,
		include_declaration = false -- Don't count the declaration itself
	},

	definition = { enabled = false },
	implementation = { enabled = false },

	-- Text formatting
	text_format = function(symbol)
		local res = {}

		if symbol.references then
			local usage = symbol.references <= 1 and 'reference' or 'references'
			table.insert(res, string.format('󰌹 %d %s', symbol.references, usage))
		end

		return table.concat(res, ', ')
	end,
})
