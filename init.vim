" Main Neovim configuration
" This file loads all the modular configuration files

" Load plugin declarations
source ~/.config/nvim/plugins.vim

" Load basic settings
source ~/.config/nvim/basic-settings.vim

" Load keybindings
source ~/.config/nvim/keybindings.vim

" Load Lua configurations
lua << EOF
-- UI and visual plugins
require('plugins.ui')

-- LSP and completion
require('plugins.lsp')

-- Treesitter for syntax highlighting
require('plugins.treesitter')

-- Git integration
require('plugins.lazygit')
require('plugins.gitsigns')


-- Window picker
require('plugins.windowpicker')



-- Debugging configuration
require('config.debug')

-- Testing configuration
require('config.testing')

-- Database client
require('config.database')

-- Session management
require('config.sessions')


require('plugins.terminal')

require('plugins.lualine')
EOF

