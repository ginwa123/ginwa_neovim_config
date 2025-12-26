" Main Neovim configuration
" Cross-platform (Linux + Windows)

let s:config = stdpath('config')

" Load plugin declarations
execute 'source ' . s:config . '/plugins.vim'

" Load basic settings
execute 'source ' . s:config . '/basic-settings.vim'

" Load keybindings
execute 'source ' . s:config . '/keybindings.vim'

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

-- Terminal & statusline
require('plugins.terminal')
require('plugins.lualine')
EOF
