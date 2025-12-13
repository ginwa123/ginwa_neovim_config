-- LSP and completion configurations

--
require("codeium").setup({
	-- enable_cmp_source = false,
	virtual_text = {
		enabled = true,

		-- These are the defaults

		-- Set to true if you never want completions to be shown automatically.
		manual = false,
		-- A mapping of filetype to true or false, to enable virtual text.
		filetypes = {},
		-- Whether to enable virtual text of not for filetypes not specifically listed above.
		default_filetype_enabled = true,
		-- How long to wait (in ms) before requesting completions after typing stops.
		idle_delay = 75,
		-- Priority of the virtual text. This usually ensures that the completions appear on top of
		-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
		-- desired.
		virtual_text_priority = 65535,
		-- Set to false to disable all key bindings for managing completions.
		map_keys = true,
		-- The key to press when hitting the accept keybinding but no completion is showing.
		-- Defaults to \t normally or <c-n> when a popup is showing.
		accept_fallback = nil,
		-- Key bindings for managing completions in virtual text mode.
		key_bindings = {
			-- Accept the current completion.
			accept = "<Tab>",
			-- Accept the next word.
			accept_word = false,
			-- Accept the next line.
			accept_line = false,
			-- Clear the virtual text.
			clear = false,
			-- Cycle to the next completion.
			next = "<M-]>",
			-- Cycle to the previous completion.
			prev = "<M-[>",
		}
	}

})
--

-- Blink completion
require('blink.cmp').setup({
	keymap = {
		['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
		['<C-e>'] = { 'hide' },
		['<CR>'] = { 'select_and_accept', 'fallback' },
		['<Tab>'] = { 'select_next', 'fallback' },
		['<S-Tab>'] = { 'select_prev', 'fallback' },
		['<C-n>'] = { 'select_next' },
		['<C-p>'] = { 'select_prev' },

		-- Ctrl + y
		['<C-y>'] = { 'select_and_accept', 'fallback' },
	},

	fuzzy = {
		prebuilt_binaries = { download = true },
		implementation = 'rust',
	},

	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer',
			-- 'dbee',
			-- 'codeium'
		},
		per_filetype = {
			-- sql = { 'snippets', 'dbee', 'buffer' },
		},
		providers = {
			-- dbee = { name = 'dbee', module = 'blink.compat.source' },
			-- codeium = { name = 'Codeium', module = 'codeium.blink', async = true },
			path = { score_offset = 3 }, -- filesystem paths
			lsp = { score_offset = 0 }, -- LSP completions (baseline)
			snippets = { score_offset = -1 }, -- code snippets
			buffer = { score_offset = -3 }, -- buffer words
		},
	},

	appearance = {
		-- use_nvim_cmp_as_default = false,
		nerd_font_variant = 'mono',

	},

	completion = {
		accept = {
			auto_brackets = { enabled = false },
		},
		menu = {
			auto_show = false,
			border = 'single',
			winblend = 0,
			scrolloff = 2,
			scrollbar = true,
			draw = {
				columns = {
					{ 'label',       'label_description', gap = 1 },
					{ 'kind_icon',   'kind',              gap = 1 },
					-- { 'type_info', },
					{ 'source_name', },
				},
				treesitter = { 'lsp' },
				components = {
					type_info = {
						text = function(ctx)
							-- Request resolve if detail is missing
							if not ctx.item.detail and ctx.item.data then
								-- This will be resolved asynchronously
								return "..."
							end
							return ctx.item.detail or ""
						end,
						highlight = "Comment",
					},
				},

			},
		},

		documentation = {
			auto_show = true,
			auto_show_delay_ms = 100,
			window = {
				border = 'single',
				winblend = 0,
			}

		},
		list = {
			selection = { preselect = false, auto_insert = true },
		},
	},

	signature = {
		enabled = true,
		trigger = {
			-- blocked_trigger_characters = {},
			-- blocked_retrigger_characters = {},
			-- Show signature when inserting a trigger character (like opening parenthesis)
			show_on_insert_on_trigger_character = true,
		},
		window = { border = 'single' }
	},
})

-- Trigger signature help after completion
vim.api.nvim_create_autocmd('CompleteDone', {
	callback = function()
		vim.defer_fn(function()
			vim.lsp.buf.signature_help()
		end, 50)
	end,
})

-- vim.api.nvim_create_autocmd({"BufWritePost"}, {
--   pattern = "*.proto",
--   callback = function()
--     vim.cmd("LspRestart")
--   end,
-- })

--
--
-- -- Custom highlight groups - Black background with white border
-- -- Completion Menu
-- vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = '#000000', fg = '#ffffff' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = '#ffffff', bg = '#000000' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { bg = '#333333', fg = '#ffffff', bold = true })
--
-- -- Scrollbar
-- vim.api.nvim_set_hl(0, 'BlinkCmpScrollBarThumb', { bg = '#ffffff' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpScrollBarGutter', { bg = '#1a1a1a' })
--
-- -- Completion Items
-- vim.api.nvim_set_hl(0, 'BlinkCmpLabel', { fg = '#ffffff' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpLabelDeprecated', { fg = '#888888', strikethrough = true })
-- vim.api.nvim_set_hl(0, 'BlinkCmpLabelMatch', { fg = '#ffffff', bold = true })
-- vim.api.nvim_set_hl(0, 'BlinkCmpLabelDetail', { fg = '#aaaaaa' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpLabelDescription', { fg = '#aaaaaa' })
--
-- -- Kind (type icons/text)
-- vim.api.nvim_set_hl(0, 'BlinkCmpKind', { fg = '#ffffff' })
--
-- -- Source
-- vim.api.nvim_set_hl(0, 'BlinkCmpSource', { fg = '#aaaaaa' })
--
-- -- Ghost text
-- vim.api.nvim_set_hl(0, 'BlinkCmpGhostText', { fg = '#555555', italic = true })
--
-- -- Documentation Window
-- vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { bg = '#000000', fg = '#ffffff' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = '#ffffff', bg = '#000000' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpDocSeparator', { fg = '#ffffff' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpDocCursorLine', { bg = '#333333' })
--
-- -- Signature Help
-- vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelp', { bg = '#000000', fg = '#ffffff' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpBorder', { fg = '#ffffff', bg = '#000000' })
-- vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpActiveParameter', { fg = '#ffffff', bold = true, underline = true })
--
--
--
-- Mason
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})
require("mason-lspconfig").setup({
	automatic_installation = true,
})
require("mason-nvim-dap").setup({
	automatic_installation = true,
	handlers = {}, -- uses default handlers → perfect for 99% of users
})

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

-- Diagnostic configuration - Disabled built-in diagnostics, using tiny-inline-diagnostic instead
vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	signs = true,
	float = { border = "rounded" },
	update_in_insert = false,
	severity_sort = true,
})


-- Tiny inline diagnostic for wrapped error messages
require('tiny-inline-diagnostic').setup({
	preset = "modern",
	options = {
		multilines = true,
		show_all_diags_on_cursorline = true,
	}
})



-- Diagnostic signs and colors
local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Enhanced diagnostic colors
vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#db4b4b", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e0af68", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#0db9d7", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#10B981", bg = "none" })

-- This makes the actual line number use the same color as the sign
vim.api.nvim_set_hl(0, "DiagnosticLineNrError", { fg = "#db4b4b", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticLineNrWarn", { fg = "#e0af68", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticLineNrInfo", { fg = "#0db9d7", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticLineNrHint", { fg = "#10B981", bg = "none" })

-- Hook it up so the number column uses these highlights
vim.cmd [[
  augroup DiagnosticLineNrColor
    autocmd!
    autocmd DiagnosticChanged * lua
      \ vim.diagnostic.setloclist({open = false})
      \ vim.diagnostic.setqflist({open = false})
  augroup END

  sign define DiagnosticSignError   texthl=DiagnosticSignError   linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn    texthl=DiagnosticSignWarn    linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo    texthl=DiagnosticSignInfo    linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint    texthl=DiagnosticSignHint    linehl= numhl=DiagnosticLineNrHint
]]

-- Force all LSP clients to use the tiny-inline-diagnostic handler
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client then
--       -- This replaces whatever handler the server or other plugins set
--       client.handlers["textDocument/publishDiagnostics"] =
--         require("tiny-inline-diagnostic").lsp_diagnostic_handler
--     end
--   end,
-- })



-- Formater
-- require("conform").setup({
-- 	formatters_by_ft = {
-- 		json = { "prettier" },
-- 		typescript = { "prettier" },
-- 		typescriptreact = { "prettier" },
-- 		javascript = { "prettier" },
-- 	},
-- }
-- )

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	pattern = "*",
-- 	callback = function(args)
-- 		require("conform").format({ bufnr = args.buf })
-- 	end,
-- })


-- ALE configuration - Use LSP diagnostics instead of running its own linters
-- vim.g.ale_disable_lsp = 0 -- Enable ALE's LSP integration (changed from 1 to 0)
--
-- -- Tell ALE to use LSP for C# (not csc/mcs)
-- vim.g.ale_linters = {
-- 	cs = { 'OmniSharp' } -- Use OmniSharp via ALE's LSP integration
-- }
--

--
-- local lsp_triggered = false
-- vim.api.nvim_create_autocmd('LspAttach', {
-- 	callback = function(args)
-- 		if not lsp_triggered then
-- 			lsp_triggered = true
-- 			vim.defer_fn(function()
-- 				vim.lsp.buf.list_workspace_folders()
-- 			end, 1000)
-- 		end
-- 	end,
-- })
