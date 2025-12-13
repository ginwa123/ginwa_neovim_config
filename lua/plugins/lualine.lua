
-- Lualine (status line)
require('lualine').setup({
	options = {
		theme = 'auto',
		component_separators = '',
		section_separators = '',
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diff' },
		lualine_c = {
			{
				'filename',
				path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
			}
		},
		lualine_x = { 'filetype' },
		lualine_y = { 'progress' },
		lualine_z = { 'location' }
	},
})
