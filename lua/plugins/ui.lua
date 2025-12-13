-- UI-related plugin configurations

-- File explorer
require("nvim-tree").setup({
	-- diagnostics = {
	--   enable = true,
	--   show_on_dirs = true,
	-- },
	update_focused_file = {
		enable = true,
		update_root = true
	},
	view = {
		width = 45,
		side = "left"
	},
	on_attach = function(bufnr)
		local api = require('nvim-tree.api')
		api.config.mappings.default_on_attach(bufnr)

		-- Override Ctrl+y to open files instead of scrolling
		vim.keymap.set('n', '<C-y>', api.node.open.edit, {
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true,
		})
	end,
})


-- Which-key
require('which-key').setup()
-- local wk = require("which-key")
-- wk.add({
-- 	{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Explorer" },
-- 	{ "<leader>w", "<cmd>w<cr>",              desc = "Save" },
-- 	{ "<leader>q", "<cmd>q<cr>",              desc = "Quit" },
-- })

-- FZF-Lua
require('fzf-lua').setup({
	keymap = {
		fzf = {
			["enter"] = "accept", -- Keep default Enter
			["ctrl-y"] = "accept", -- Add Ctrl+Y as alternative
		},
	},
})
require('fzf-lua').register_ui_select()

-- Smooth scroll with neoscroll
-- local neoscroll = require('neoscroll')
-- vim.keymap.set("", "<ScrollWheelUp>", function()
--   neoscroll.scroll(-3, { move_cursor = false, duration = 0 })
-- end, { silent = true })
--
-- vim.keymap.set("", "<ScrollWheelDown>", function()
--   neoscroll.scroll(3, { move_cursor = false, duration = 0 })
-- end, { silent = true })
--
-- Smear cursor

if vim.g.neovide then
  require("smear_cursor").enabled = false
else
  require("smear_cursor").enabled = true
end

-- Indent lines`
require("ibl").setup()


-- require('mini.animate').setup()
