---@diagnostic disable-next-line: undefined-global
local vim = vim


-- Treesitter configuration
require('nvim-treesitter').setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	ensure_installed = { "elixir", "heex", "eex" },
	matchup = {
		enable = true,
	},
})

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = {"*.ex", "*.exs", "*.heex", "*.leex"},
  callback = function()
    local ts_highlight = require('vim.treesitter.highlighter')
    if not ts_highlight.active[vim.api.nvim_get_current_buf()] then
      vim.treesitter.start()
    end
  end,
})


require 'treesitter-context'.setup {
	enable = true
}
