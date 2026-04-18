require("aerial").setup({
	layout = {
		default_direction = "left",
	},

	on_attach = function(bufnr)
		vim.keymap.set("n", "<C-y>", function()
			require("aerial").toggle()
		end, { buffer = bufnr, desc = "Toggle Aerial" })
	end,
})
