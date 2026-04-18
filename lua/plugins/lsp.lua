---@diagnostic disable-next-line: undefined-global
local vim = vim

require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})

-- LSP and completion configurations

-- --
-- require("codeium").setup({
-- 	-- enable_cmp_source = false,
-- 	virtual_text = {
-- 		enabled = true,
--
-- 		-- These are the defaults
--
-- 		-- Set to true if you never want completions to be shown automatically.
-- 		manual = false,
-- 		-- A mapping of filetype to true or false, to enable virtual text.
-- 		filetypes = {},
-- 		-- Whether to enable virtual text of not for filetypes not specifically listed above.
-- 		default_filetype_enabled = true,
-- 		-- How long to wait (in ms) before requesting completions after typing stops.
-- 		idle_delay = 75,
-- 		-- Priority of the virtual text. This usually ensures that the completions appear on top of
-- 		-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
-- 		-- desired.
-- 		virtual_text_priority = 65535,
-- 		-- Set to false to disable all key bindings for managing completions.
-- 		map_keys = true,
-- 		-- The key to press when hitting the accept keybinding but no completion is showing.
-- 		-- Defaults to \t normally or <c-n> when a popup is showing.
-- 		accept_fallback = nil,
-- 		-- Key bindings for managing completions in virtual text mode.
-- 		key_bindings = {
-- 			-- Accept the current completion.
-- 			accept = "<Tab>",
-- 			-- Accept the next word.
-- 			accept_word = false,
-- 			-- Accept the next line.
-- 			accept_line = false,
-- 			-- Clear the virtual text.
-- 			clear = false,
-- 			-- Cycle to the next completion.
-- 			next = "<M-]>",
-- 			-- Cycle to the previous completion.
-- 			prev = "<M-[>",
-- 		}
-- 	}
--
-- })
--
--
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
		implementation = "prefer_rust",
		prebuilt_binaries = {
			force_version = "latest",
		},
	},

	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer',
			'supermaven',
			-- 'cinvimsql'
			-- 'dbee',
			-- 'codeium'
		},
		per_filetype = {
			-- sql = { 'snippets', 'dbee', 'buffer' },
		},
		providers = {
			supermaven = {
				name = "supermaven",
				module = "blink.compat.source",
				score_offset = 3,
			},
			-- ginvimsql = {
			-- 	name = "ginvimsql",
			-- 	module = "blink.compat.source",
			-- 	score_offset = 1
			-- },

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
			selection = { preselect = false, auto_insert = false },
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

local function toggle_inlay_hints()
	local bufnr = vim.api.nvim_get_current_buf()
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
end

vim.keymap.set("n", "<leader>ih", toggle_inlay_hints, {
	desc = "Toggle LSP inlay hints",
})



require("mason-lspconfig").setup({
	automatic_installation = true,

})
require("mason-nvim-dap").setup({
	automatic_installation = true,
	handlers = {}, -- uses default handlers → perfect for 99% of users
})

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

lspconfig.ts_ls.setup({
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vim.fn.stdpath("data") ..
				    "/mason/packages/vue-language-server/node_modules/@vue/language-server",
				languages = { "javascript", "typescript", "vue" },
			},
		},
	},
	filetypes = {
		"javascript",
		"typescript",
		"vue",
	},
})

if not configs["zig-lsp-sql"] then
	configs["zig-lsp-sql"] = {
		default_config = {
			name = "zig-lsp-sql", -- MUST match server's reported name!
			cmd = { "/home/ginwa/ginvimsql/agent1/zig-lsp-sql/zig-out/bin/zig-lsp-sql" },
			filetypes = { "sql" },
			-- root_dir = function()
			--   return vim.fn.getcwd()
			-- end,
			single_file_support = true,
		},
	}
end

lspconfig["zig-lsp-sql"].setup({})


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


-- enable the language server
vim.lsp.enable('kotlin_lsp')

-- configure language server's options
vim.lsp.config('kotlin_lsp', {
	single_file_support = false,
})
