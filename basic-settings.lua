---@diagnostic disable-next-line: undefined-global
local vim = vim

vim.o.autoread = true

-- Basic Neovim settings
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Fix yank (paste over selection without yanking deleted text)
vim.keymap.set("x", "p", '"_dP', { desc = "Paste over selection without yanking deleted text" })

vim.opt.foldmethod = 'syntax'
vim.opt.foldlevel = 99

-- Colorscheme
-- vim.cmd.colorscheme("kanagawa-dragon")
-- vim.cmd.colorscheme("github_dark_high_contrast")
vim.cmd.colorscheme("kanagawa-dragon")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- Transparent background
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" }) -- Transaparent background

-- Show line numbers
vim.opt.number = true

-- Show cursor
vim.opt.cursorline = true


-- UI improvements
vim.opt.showmode = false
vim.opt.showcmd = false
-- vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.fillchars = {
	vert = " ",
	horiz = " ",
	horizup = " ",
	horizdown = " ",
	vertleft = " ",
	vertright = " ",
	verthoriz = " ",
}
vim.opt.smartindent = true

-- Disable netrw (for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.relativenumber = false

-- Remap arrow keys in normal mode to hjkl
vim.keymap.set("n", "<Up>", "k")
vim.keymap.set("n", "<Down>", "j")
vim.keymap.set("n", "<Left>", "h")
vim.keymap.set("n", "<Right>", "l")

-- Custom command for nvim-tree
vim.api.nvim_create_user_command("Tree", "NvimTreeToggle", {})

vim.opt.spelllang = { "en" }

-- === Neovide specific settings ===
if vim.g.neovide then
	-- Paste with Ctrl+Shift+V
	vim.keymap.set("n", "<C-S-v>", '"+P')
	vim.keymap.set("v", "<C-S-v>", '"+P')
	vim.keymap.set("i", "<C-S-v>", '<Esc>"+pA')
	vim.keymap.set("c", "<C-S-v>", "<C-r>+")
	vim.keymap.set("t", "<C-S-v>", '<C-\\><C-n>"+pa')

	-- Copy with Ctrl+Shift+C
	vim.keymap.set("n", "<C-S-c>", '"+y')
	vim.keymap.set("v", "<C-S-c>", '"+y')
	vim.keymap.set("i", "<C-S-c>", '<Esc>"+yA')

	-- Special handling for fzf-lua prompt (terminal buffer)
	local augroup = vim.api.nvim_create_augroup("NeovideFzfPaste", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = "fzf",
		callback = function()
			vim.keymap.set("t", "<C-S-v>", '<C-\\><C-n>"+pA', { buffer = true })
			vim.keymap.set("i", "<C-S-v>", '<C-o>"+p<C-o>A', { buffer = true })
		end,
	})

	-- Animation settings
	vim.g.neovide_scroll_animation_length = 0.05

	-- Transparency settings
	vim.g.neovide_opacity = 0.80
	vim.g.neovide_background_color = "#000000"
	vim.g.neovide_background_top_color = "#00000000"
	vim.g.neovide_background_bottom_color = "#00000000"

	-- Floating windows blur
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0
end

-- Moonfly colorscheme transparency
vim.g.moonflyTransparent = 1
