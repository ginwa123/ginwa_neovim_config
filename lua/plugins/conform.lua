require("conform").setup({
	formatters_by_ft = {
		-- Specify Biome for relevant file types
		javascript = { "biome" },
		typescript = { "biome" },
		javascriptreact = { "biome" },
		typescriptreact = { "biome" },
		json = { "biome" },
		jsonc = { "biome" },
		-- Add other languages as needed
	},

	-- format_on_save = {
	-- 	timeout_ms = 500,
	-- 	lsp_fallback = true,
	-- },
	-- formatters = {
	-- 	biome = {
	-- 		-- Only run biome if a biome.json config file exists in the project root
	-- 		require_cwd = true,
	-- 	},
	-- },
})
