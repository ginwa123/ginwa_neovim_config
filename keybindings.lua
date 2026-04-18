---@diagnostic disable-next-line: undefined-global
local vim = vim

-- Keybindings and mappings
-- Diagnostic navigation
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({
		severity = vim.diagnostic.severity.ERROR,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Next ERROR" })

vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({
		severity = vim.diagnostic.severity.ERROR,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Previous ERROR" })

vim.keymap.set("n", "]w", function()
	vim.diagnostic.goto_next({
		severity = vim.diagnostic.severity.WARN,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Next WARNING" })

vim.keymap.set("n", "[w", function()
	vim.diagnostic.goto_prev({
		severity = vim.diagnostic.severity.WARN,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Previous WARNING" })

vim.keymap.set("n", "]h", function()
	vim.diagnostic.goto_next({
		severity = vim.diagnostic.severity.HINT,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Next HINT" })

vim.keymap.set("n", "[h", function()
	vim.diagnostic.goto_prev({
		severity = vim.diagnostic.severity.HINT,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Previous HINT" })

vim.keymap.set("n", "[q", function()
	vim.diagnostic.goto_prev({
		severity = vim.diagnostic.severity.QUICKFIX,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Previous QUICKFIX" })

vim.keymap.set("n", "]q", function()
	vim.diagnostic.goto_next({
		severity = vim.diagnostic.severity.QUICKFIX,
		float = { border = "rounded", focusable = false }
	})
end, { silent = true, desc = "Next QUICKFIX" })

-- Neovim tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- CORE LSP ACTIONS (C# with OmniSharp) // rename with leader cr
vim.keymap.set("n", "<leader>cr", function()
	vim.lsp.buf.rename()
end, { desc = "Rename symbol" })
-- vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })


vim.keymap.set("n", "gr", function()
	require("fzf-lua").lsp_references()
end, { desc = "Find all references" })

-- FZF keybindings
vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader><space>", function()
	require("fzf-lua").live_grep({ resume = true })
end, { desc = "Live grep (ripgrep)" })


vim.keymap.set("n", "<leader>S", function()
	require("fzf-lua").live_grep({ resume = false })
end, { desc = "Grep (ripgrep fresh)" })

vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "Find buffers" })

vim.keymap.set("n", "<leader>fl", function()
	require("fzf-lua").lines()
end, { desc = "Find lines in current file" })

vim.keymap.set("n", "<leader>fgf", function()
	require("fzf-lua").git_files()
end, { desc = "Git tracked files" })

vim.keymap.set("n", "<leader>fgs", function()
	require("fzf-lua").git_status()
end, { desc = "Git status (modified files)" })

vim.keymap.set("n", "<leader>fgp", function()
	require("fzf-lua").git_diff({
		git_args = "diff origin/HEAD..HEAD",
	})
end, { desc = "Git unpushed commits (not yet pushed)" })

vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").oldfiles()
end, { desc = "File history (oldfiles)" })

vim.keymap.set("n", "<leader>fds", function()
	require("fzf-lua").lsp_document_symbols()
end, { desc = "Document symbols" })

vim.keymap.set("n", "<leader>fdS", function()
	require("fzf-lua").lsp_workspace_symbols()
end, { desc = "LSP Workspace symbols" })


vim.keymap.set("n", "<leader>fe", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
	vim.cmd("copen")
end, { silent = true, desc = "Error list (quickfix)" })

vim.keymap.set("n", "<leader>fw", function()
	require("fzf-lua").diagnostics_workspace({ severity_limit = "WARN" })
end, { silent = true, desc = "Warning list (quickfix)" })

-- Code action / quick fix
vim.keymap.set("n", "<leader>ca", function()
	require("fzf-lua").lsp_code_actions()
end, { desc = "Code actions" })

vim.keymap.set("v", "<leader>ca", function()
	require("fzf-lua").lsp_code_actions()
end, { desc = "Code actions (visual)" })

-- Hover / show documentation
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover documentation" })

-- Go to definition
vim.keymap.set("n", "gd", function()
	require("fzf-lua").lsp_definitions()
end, { silent = true, desc = "Go to definition" })

-- Go to implementation
vim.keymap.set("n", "gi", function()
	require("fzf-lua").lsp_implementations()
end, { desc = "Go to implementation" })

-- Go to type definition
vim.keymap.set("n", "gy", function()
	require("fzf-lua").lsp_type_definitions()
end, { desc = "Go to type definition" })

-- Format entire file (REPLACED WITH CONFORM)
vim.keymap.set("n", "<leader>faf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file" })

-- Format selection (REPLACED WITH CONFORM)
vim.keymap.set("v", "<leader>faf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format selection" })

-- Error diagnostics using fzf
vim.keymap.set("n", "<leader>fe", function()
	require("fzf-lua").diagnostics_workspace({ severity_limit = "ERROR" })
end, { desc = "Workspace error diagnostics" })

-- Debug keybindings
vim.keymap.set("n", "<leader>bl", function()
	require("fzf-lua").dap_breakpoints()
end, { desc = "List breakpoints" })

vim.keymap.set("n", "<leader>vl", function()
	require("fzf-lua").dap_variables()
end, { silent = true, desc = "List debug variables" })

vim.keymap.set("n", "<leader>gar", function()
	require("grug-far").open()
end, { silent = true, desc = "Open grug-far find and replace" })

-- Debug keybindings
vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end, { desc = "Debug: Continue/Start" })

vim.keymap.set("n", "<F10>", function()
	require("dap").step_over()
end, { desc = "Debug: Step over" })

vim.keymap.set("n", "<F11>", function()
	require("dap").step_into()
end, { desc = "Debug: Step into" })

vim.keymap.set("n", "<F12>", function()
	require("dap").step_out()
end, { desc = "Debug: Step out" })

vim.keymap.set("n", "gb", function()
	require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle breakpoint" })

vim.keymap.set('n', 'gB', function()
	require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug: Conditional breakpoint' })

vim.keymap.set("n", "<F6>", "<cmd>DapViewToggle<CR>", { desc = "Debug: Toggle DAP view" })

-- Test keybindings
vim.keymap.set("n", "<leader>tt", function()
	run_test_with_correct_cwd("nearest")
end, { desc = "Test: Run nearest" })

vim.keymap.set("n", "<leader>tf", function()
	run_test_with_correct_cwd("file")
end, { desc = "Test: Run file" })

vim.keymap.set("n", "<leader>tp", function()
	run_test_with_correct_cwd("project")
end, { desc = "Test: Run project" })

vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { desc = "Test: Toggle summary" })

vim.keymap.set("n", "<leader>to", function()
	require("neotest").output.open({ enter = true })
end, { desc = "Test: Open output" })

vim.keymap.set("n", "<leader>tO", function()
	require("neotest").output_panel.toggle()
end, { desc = "Test: Toggle output panel" })

vim.keymap.set("n", "<leader>td", function()
	vim.notify("Project root: " .. find_nearest_project_or_solution(), vim.log.levels.INFO)
end, { desc = "Test: Show project root" })

-- Undotree
vim.keymap.set("n", "<leader>tu", "<cmd>UndotreeToggle<CR>", { desc = "Toggle UndoTree" })

-- Leap jump (bidirectional by default for faster targeting)
vim.keymap.set("n", "s", "<Plug>(leap)", { desc = "Leap jump" })
vim.keymap.set("x", "s", "<Plug>(leap)", { desc = "Leap jump (visual)" })
vim.keymap.set("o", "s", "<Plug>(leap)", { desc = "Leap jump (operator)" })
vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap from window" })

-- Treesitter-aware node jumping (requires nvim-treesitter)
vim.keymap.set({ "n", "x", "o" }, "<leader>n", function()
	require("leap.treesitter").select()
end, { desc = "Leap: select treesitter node" })

do
	local function ft(key_specific_args)
		require("leap").leap(
			vim.tbl_deep_extend("keep", key_specific_args, {
				inputlen = 1,
				inclusive = true,
				opts = {
					preview = false,
					labels = "",
					safe_labels = vim.fn.mode(1):match("o") and "" or nil,
				},
			})
		)
	end

	local clever = require("leap.user").with_traversal_keys
	local clever_f, clever_t = clever("f", "F"), clever("t", "T")

	vim.keymap.set({ "n", "x", "o" }, "f", function() ft { opts = clever_f } end)
	vim.keymap.set({ "n", "x", "o" }, "F", function() ft { backward = true, opts = clever_f } end)
	vim.keymap.set({ "n", "x", "o" }, "t", function() ft { offset = -1, opts = clever_t } end)
	vim.keymap.set({ "n", "x", "o" }, "T", function() ft { backward = true, offset = 1, opts = clever_t } end)
end

-- ─── Leap opts tuning ──────────────────────────────────────────────────────

require("leap").opts = vim.tbl_deep_extend("force", require("leap").opts, {
	-- Prioritize characters closer to the cursor when assigning labels,
	-- so the most-reachable labels land on nearby targets.
	-- (already default in recent leap, but make it explicit)
	case_sensitive = false,

	-- Extend the label set so you never run out on dense buffers.
	-- Home-row biased: prioritize keys you can hit without moving your hand.
	labels = "sfnjklhodweimbuyvrgtaqpcxz/",
	safe_labels = "sfnjklhodweimbuyvrgtaqpcxz/",

	-- Show the leap cursor while mid-jump so you always know where you'll land.
	preview = true,

	-- Equivalence classes: treat these as interchangeable when searching.
	-- Lets you type a plain char to match its accented variants.
	equivalence_classes = {
		" \t\r\n", -- any whitespace matches any other whitespace
		"aáàâä",
		"eéèêë",
		"iíìîï",
		"oóòôö",
		"uúùûü",
	},
})

-- ─── Highlight tweaks ──────────────────────────────────────────────────────
-- Make labels visually pop without being jarring.

-- Steal colors from existing highlight groups so Leap always matches your theme
local function hl_fg(group)
	return vim.api.nvim_get_hl(0, { name = group, link = false }).fg
end

vim.api.nvim_set_hl(0, "LeapLabel", { fg = hl_fg("DiagnosticError"), bold = true, nocombine = true })
vim.api.nvim_set_hl(0, "LeapMatch", { fg = hl_fg("DiagnosticInfo"), bold = true, nocombine = true })
vim.api.nvim_set_hl(0, "LeapLabelPrimary", { fg = hl_fg("DiagnosticError"), bold = true, nocombine = true })
vim.api.nvim_set_hl(0, "LeapLabelSecondary", { fg = hl_fg("DiagnosticHint"), bold = true, nocombine = true })

-- Jump list navigation
vim.keymap.set("n", "<F13>", "<C-o>", { desc = "Jump backward" })
vim.keymap.set("n", "<F14>", "<C-i>", { desc = "Jump forward" })

-- Disable caps lock
vim.keymap.set("i", "<CapsLock>", "<Nop>", { desc = "Disable CapsLock" })
vim.keymap.set("n", "<CapsLock>", "<Nop>", { desc = "Disable CapsLock" })
vim.keymap.set("v", "<CapsLock>", "<Nop>", { desc = "Disable CapsLock" })

-- Git reset hunk
vim.keymap.set("x", "<leader>grh", function()
	require("gitsigns").reset_hunk()
end, { desc = "Git: Reset hunk" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer navigation
vim.keymap.set("n", "<A-n>", ":bn<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<A-p>", ":bp<CR>", { desc = "Previous buffer" })

-- Window picker
-- vim.keymap.set("n", "<A-w>", function()
-- 	local win = require('window-picker').pick_window({ hint = "floating-big-letter" })
-- 	if win ~= nil then
-- 		vim.api.nvim_set_current_win(win)
-- 	end
-- end, { desc = "Pick window" })

vim.keymap.set("n", "<leader>sw", function()
	local win = require('window-picker').pick_window({ hint = "floating-big-letter" })
	if win ~= nil then
		vim.api.nvim_set_current_win(win)
	end
end, { silent = true, desc = "Pick window" })


vim.keymap.set("n", "<A-h>", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<A-v>", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<A-c>", "<C-w>c", { desc = "Close window" })

-- Escape terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Grug-far
vim.keymap.set("n", "<leader>sr", function()
	local grug_far = require("grug-far")
	grug_far.open()
end, { silent = true, desc = "Search and replace (grug-far)" })

-- git vertical diff split
vim.keymap.set("n", "<leader>gvd", function()
	vim.cmd("Gvdiffsplit")
end, { silent = true, desc = "Git: Diff this file" })

-- git hunk navigation
vim.keymap.set("n", "]c", function()
	if vim.wo.diff then return "]c" end
	vim.schedule(function()
		require("gitsigns").next_hunk({ staged = nil })
	end)
	return "<Ignore>"
end, { expr = true })

vim.keymap.set("n", "[c", function()
	if vim.wo.diff then return "[c" end
	vim.schedule(function()
		require("gitsigns").prev_hunk({ staged = nil })
	end)
	return "<Ignore>"
end, { expr = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- refresh config file
vim.keymap.set("n", "<leader>rr", function()
	vim.cmd("source $MYVIMRC")
end, { silent = true, desc = "Reload config file" })

-- toggle treesitter context
vim.keymap.set("n", "<leader>tc", function()
	vim.cmd("TSContext")
end, { silent = true, desc = "Toggle treesitter context" })

-- DAP
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Continue/Start' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })

vim.keymap.set('n', '<leader>bc', function()
	require('dap').clear_breakpoints()
	vim.notify('All breakpoints cleared', vim.log.levels.INFO)
end, { desc = 'Debug: Clear All Breakpoints' })

vim.keymap.set('n', 'gb', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })



vim.keymap.set("n", "]]", function()
	require("illuminate").goto_next_reference(false)
end, { desc = "Next reference" })

vim.keymap.set("n", "[[", function()
	require("illuminate").goto_prev_reference(false)
end, { desc = "Previous reference" })


vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")


-- Disable the default Ctrl+Z suspend behavior by mapping it to a no-op
vim.api.nvim_set_keymap('n', '<C-z>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-z>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-z>', '<Nop>', { noremap = true, silent = true })


-- copie error diagnostic
vim.keymap.set('n', '<leader>yD', function()
	local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
	if #diags > 0 then
		vim.fn.setreg('+', diags[1].message)
		vim.notify("Copied: " .. diags[1].message)
	end
end)
