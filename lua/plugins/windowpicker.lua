require('window-picker').setup({
	hint = 'floating-big-letter',
	selection_chars = '12345;qwert',
	filter_rules = {
		include_current_win = false,
		autoselect_one = false,
		-- Remove or comment out the filtering
		bo = {
			filetype = {}, -- Empty means don't filter out any filetypes
			buftype = {}, -- Empty means don't filter out any buftypes
		},
	},
})
-- --

