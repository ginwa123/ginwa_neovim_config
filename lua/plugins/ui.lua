---@diagnostic disable-next-line: undefined-global
local vim = vim

-- UI-related plugin configurations

-- File explorer
require("nvim-tree").setup({
	-- diagnostics = {
	--   enable = true,
	--   show_on_dirs = true,
	-- },
	update_focused_file = {
		enable = true,
		-- update_root = true
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


if vim.g.neovide then
	require("smear_cursor").enabled = false
else
	-- require("smear_cursor").enabled = false

	local smear_cursor = require("smear_cursor")
	smear_cursor.setup({
		opts = {                  -- Default  Range
			stiffness = 0.8,  -- 0.6      [0, 1]
			trailing_stiffness = 0.6, -- 0.45     [0, 1]
			stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
			trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
			damping = 0.95,   -- 0.85     [0, 1]
			damping_insert_mode = 0.95, -- 0.9      [0, 1]
			distance_stop_animating = 0.5, -- 0.1      > 0
		},
	})
end

-- Indent lines`
-- require("ibl").setup()


--
require('mini.move').setup()
