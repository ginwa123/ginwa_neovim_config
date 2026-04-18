" Plugin declarations using vim-plug
call plug#begin()

" UI and Visual
Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'nvim-tree/nvim-tree.lua' " file explorer
Plug 'nvim-lualine/lualine.nvim' " bottom lualine
Plug 'sphamba/smear-cursor.nvim' " cursor animationa
Plug 'mbbill/undotree' " to toogle undotree
"Plug 'lukas-reineke/indent-blankline.nvim' " show indentation blankline
Plug 'nvim-mini/mini.icons', { 'branch': 'stable' }
"Plug 'RRethy/vim-illuminate' " highlight current word

" Themes colorschemes
Plug 'rebelot/kanagawa.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'bluz71/vim-moonfly-colors'
Plug 'projekt0n/github-nvim-theme'
Plug 'webhooked/kanso.nvim'
"Plug 'morhetz/gruvbox'
Plug 'uhs-robert/oasis.nvim'
Plug 'sainnhe/gruvbox-material'
Plug 'altercation/vim-colors-solarized'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'uhs-robert/oasis.nvim'


" Navigation and Search
Plug 'folke/which-key.nvim' " to show keymaps
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ibhagwan/fzf-lua'
Plug 'MagicDuck/grug-far.nvim' " search and replace across files
Plug 'https://codeberg.org/andyg/leap.nvim' " to move around line using key f
Plug 's1n7ax/nvim-window-picker' " to select window in current buffer
Plug 'nvim-mini/mini.move', { 'branch': 'stable' } " to move selection code block up or down
Plug 'andymass/vim-matchup'
Plug 'stevearc/aerial.nvim'

" Git Integration
Plug 'lewis6991/gitsigns.nvim' " show git sign like add,update,delete etc
Plug 'tpope/vim-fugitive'
Plug 'kdheepak/lazygit.nvim' " git integration
" Plug
Plug 'sindrets/diffview.nvim'

" LSP and Completion
Plug 'neovim/nvim-lspconfig'
Plug 'saghen/blink.cmp', { 'tag': '*', 'do': 'cargo build --release' } " CMP
Plug 'saghen/blink.compat' " CMP Addon
Plug 'mason-org/mason.nvim' " LSP package manager
Plug 'mason-org/mason-lspconfig.nvim'
Plug 'Wansmer/symbol-usage.nvim' " show count of symbol usage
Plug 'rachartier/tiny-inline-diagnostic.nvim' " pretty inline diagnostic
Plug 'rafamadriz/friendly-snippets' " snippets code integrated with blink cmp
Plug 'elixir-tools/elixir-tools.nvim', { 'tag': 'stable' }
Plug 'stevearc/conform.nvim'
"Plug 'seblyng/roslyn.nvim'

" AI and Code Assistance
"Plug 'Exafunction/windsurf.nvim', { 'branch': 'main' }
Plug 'supermaven-inc/supermaven-nvim' " AI assistant

" Syntax and Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'main'}
Plug 'nvim-treesitter/nvim-treesitter-context'
"Plug 'nvim-treesitter/nvim-treesitter-textobjects'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-neotest/nvim-nio'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'jay-babu/mason-nvim-dap.nvim'
Plug 'igorlfs/nvim-dap-view'

" Testing
Plug 'nvim-lua/plenary.nvim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-neotest/nvim-nio'
Plug 'nvim-neotest/neotest'
Plug 'Issafalcon/neotest-dotnet'

call plug#end()

