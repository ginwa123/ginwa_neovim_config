---@diagnostic disable-next-line: undefined-global
local vim = vim

-- =========================================================
-- Mason
-- =========================================================

require("mason").setup({
})

require("mason-lspconfig").setup({
	automatic_installation = true,
})

require("mason-nvim-dap").setup({
	automatic_installation = true,
	handlers = {},
})

-- =========================================================
-- Blink CMP
-- =========================================================

require("blink.cmp").setup({
	keymap = {
		["<C-Space>"] = {
			"show",
			"show_documentation",
			"hide_documentation",
		},

		["<C-e>"] = { "hide" },
		["<CR>"] = { "select_and_accept", "fallback" },

		["<Tab>"] = {
			"select_next",
			"fallback",
		},

		["<S-Tab>"] = {
			"select_prev",
			"fallback",
		},

		["<C-n>"] = { "select_next" },
		["<C-p>"] = { "select_prev" },

		["<C-y>"] = {
			"select_and_accept",
			"fallback",
		},
	},

	fuzzy = {
		implementation = "prefer_rust",

		prebuilt_binaries = {
			force_version = "latest",
		},
	},

	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
			"supermaven",
		},

		per_filetype = {},

		providers = {
			supermaven = {
				name = "supermaven",
				module = "blink.compat.source",
				score_offset = 3,
			},

			path = {
				score_offset = 3,
			},

			lsp = {
				score_offset = 0,
			},

			snippets = {
				score_offset = -1,
			},

			buffer = {
				score_offset = -3,
			},
		},
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		accept = {
			auto_brackets = {
				enabled = false,
			},
		},

		menu = {
			auto_show = false,
			border = "single",
			winblend = 0,
			scrolloff = 2,
			scrollbar = true,

			draw = {
				columns = {
					{
						"label",
						"label_description",
						gap = 1,
					},

					{
						"kind_icon",
						"kind",
						gap = 1,
					},

					{
						"source_name",
					},
				},

				treesitter = { "lsp" },

				components = {
					type_info = {
						text = function(ctx)
							if not ctx.item.detail and ctx.item.data then
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
				border = "single",
				winblend = 0,
			},
		},

		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
	},

	signature = {
		enabled = true,

		trigger = {
			show_on_insert_on_trigger_character = true,
		},

		window = {
			border = "single",
		},
	},
})

-- =========================================================
-- Signature Help
-- =========================================================

vim.api.nvim_create_autocmd("CompleteDone", {
	callback = function()
		vim.defer_fn(function()
			vim.lsp.buf.signature_help()
		end, 50)
	end,
})

-- =========================================================
-- Inlay Hints
-- =========================================================

local function toggle_inlay_hints()
	local bufnr = vim.api.nvim_get_current_buf()

	local enabled = vim.lsp.inlay_hint.is_enabled({
		bufnr = bufnr,
	})

	vim.lsp.inlay_hint.enable(not enabled, {
		bufnr = bufnr,
	})
end

vim.keymap.set("n", "<leader>ih", toggle_inlay_hints, {
	desc = "Toggle LSP inlay hints",
})

-- =========================================================
-- Helper
-- =========================================================

local function lsp(name, opts)
	vim.lsp.config(name, opts or {})
	vim.lsp.enable(name)
end

-- =========================================================
-- Capabilities
-- =========================================================

local capabilities = require("blink.cmp").get_lsp_capabilities()

-- =========================================================
-- TypeScript / Vue
-- =========================================================

lsp("ts_ls", {
	capabilities = capabilities,

	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",

				location = vim.fn.stdpath("data")
				    .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",

				languages = {
					"javascript",
					"typescript",
					"vue",
				},
			},
		},
	},

	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
	},
})

-- =========================================================
-- Vue
-- =========================================================

lsp("vue_ls", {
	capabilities = capabilities,
})

-- =========================================================
-- Lua
-- =========================================================

lsp("lua_ls", {
	capabilities = capabilities,

	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},

			workspace = {
				checkThirdParty = false,
			},

			telemetry = {
				enable = false,
			},
		},
	},
})

-- =========================================================
-- Zig
-- =========================================================

lsp("zls", {
	capabilities = capabilities,
})

-- =========================================================
-- Rust
-- =========================================================

lsp("rust_analyzer", {
	capabilities = capabilities,
})

-- =========================================================
-- Kotlin
-- =========================================================

lsp("kotlin_lsp", {
	capabilities = capabilities,
	single_file_support = false,
})

-- =========================================================
-- Elixir
-- =========================================================

lsp("elixirls", {
	capabilities = capabilities,
})

-- =========================================================
-- Go
-- =========================================================

lsp("gopls", {
	capabilities = capabilities,

	settings = {
		gopls = {
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
})

-- =========================================================
-- SQL Custom Server
-- =========================================================

lsp("zig-lsp-sql", {
	cmd = {
		"/home/ginwa/ginvimsql/agent1/zig-lsp-sql/zig-out/bin/zig-lsp-sql",
	},

	filetypes = {
		"sql",
	},

	single_file_support = true,

	capabilities = capabilities,
})

-- =========================================================
-- Diagnostics
-- =========================================================

vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	signs = true,

	float = {
		border = "rounded",
	},

	update_in_insert = false,
	severity_sort = true,
})

-- =========================================================
-- Tiny Inline Diagnostic
-- =========================================================

require("tiny-inline-diagnostic").setup({
	preset = "modern",

	options = {
		multilines = true,
		show_all_diags_on_cursorline = true,
	},
})

-- =========================================================
-- Diagnostic Signs
-- =========================================================

local signs = {
	Error = "✘",
	Warn = "▲",
	Hint = "⚑",
	Info = "»",
}

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type

	vim.fn.sign_define(hl, {
		text = icon,
		texthl = hl,
		numhl = hl,
	})
end

vim.api.nvim_set_hl(0, "DiagnosticSignError", {
	fg = "#db4b4b",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticSignWarn", {
	fg = "#e0af68",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticSignInfo", {
	fg = "#0db9d7",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticSignHint", {
	fg = "#10B981",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticLineNrError", {
	fg = "#db4b4b",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticLineNrWarn", {
	fg = "#e0af68",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticLineNrInfo", {
	fg = "#0db9d7",
	bg = "none",
})

vim.api.nvim_set_hl(0, "DiagnosticLineNrHint", {
	fg = "#10B981",
	bg = "none",
})

vim.cmd([[
  augroup DiagnosticLineNrColor
    autocmd!

    autocmd DiagnosticChanged * lua
      \ vim.diagnostic.setloclist({open = false})
      \ vim.diagnostic.setqflist({open = false})

  augroup END

  sign define DiagnosticSignError texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn  texthl=DiagnosticSignWarn  linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo  texthl=DiagnosticSignInfo  linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint  texthl=DiagnosticSignHint  linehl= numhl=DiagnosticLineNrHint
]])
