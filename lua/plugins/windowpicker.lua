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
vim.keymap.set("n", "<A-w>", function()
	local win = require('window-picker').pick_window({ hint = "floating-big-letter" })
	if win ~= nil then
		vim.api.nvim_set_current_win(win)
	end
end)

vim.keymap.set("n", "<A-h>", ":split<CR>")
vim.keymap.set("n", "<A-v>", ":vsplit<CR>")
vim.keymap.set("n", "<A-c>", "<C-w>c")
