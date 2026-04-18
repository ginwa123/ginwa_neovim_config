" Main Neovim configuration
" This file loads all the modular configuration files

" Set leader key BEFORE loading plugins
lua << EOF
vim.g.mapleader = " "
EOF

" Load plugin declarations
source ~/.config/nvim/plugins.vim

" Load basic settings
source ~/.config/nvim/basic-settings.lua

" Load keybindings
source ~/.config/nvim/keybindings.lua

" Load Lua configurations
lua << EOF
-- UI and visual plugins
require('plugins.ui')

-- LSP and completion
require('plugins.lsp')

require('plugins.elixir')

-- Treesitter for syntax highlighting
require('plugins.treesitter')

-- Git integration
require('plugins.lazygit')
require('plugins.gitsigns')

-- Window picker
require('plugins.windowpicker')

-- Debugging configuration
require('plugins.debug')

-- Testing configuration
require('plugins.testing')

require('plugins.lualine')

require('plugins.experimental')

require('plugins.ai_autocomplete')

require('plugins.symbol_usage')

require('plugins.conform')

require('plugins.aerial')

require('plugins.which_key')

EOF

