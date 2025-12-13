" Plugin declarations using vim-plug
call plug#begin()

" UI and Visual
Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim',
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'projekt0n/github-nvim-theme'
Plug 'sphamba/smear-cursor.nvim'
Plug 'mbbill/undotree'
Plug 'bluz71/vim-moonfly-colors'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}


" Navigation and Search
Plug 'folke/which-key.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ibhagwan/fzf-lua'
Plug 'MagicDuck/grug-far.nvim'
Plug 'ggandor/leap.nvim'
Plug 's1n7ax/nvim-window-picker'
Plug 'goolord/alpha-nvim'

" Git Integration
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
Plug 'kdheepak/lazygit.nvim'

" LSP and Completion
Plug 'neovim/nvim-lspconfig'
Plug 'saghen/blink.cmp', { 'tag': '*', 'do': 'cargo build --release' }
Plug 'saghen/blink.compat'
Plug 'mason-org/mason.nvim'
Plug 'mason-org/mason-lspconfig.nvim'
Plug 'Wansmer/symbol-usage.nvim'
Plug 'rachartier/tiny-inline-diagnostic.nvim'
"Plug 'stevearc/conform.nvim'
Plug 'rafamadriz/friendly-snippets'

" AI and Code Assistance
Plug 'Exafunction/windsurf.nvim', { 'branch': 'main' }

" Syntax and Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

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
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-neotest/nvim-nio'
Plug 'nvim-neotest/neotest'
Plug 'Issafalcon/neotest-dotnet'

" Database
"Plug 'MunifTanjim/nui.nvim'
"Plug 'kndndrj/nvim-dbee'
"Plug 'MattiasMTS/cmp-dbee'
"
"Plug 'tpope/vim-dadbod'
"Plug 'kristijanhusak/vim-dadbod-ui'
"Plug 'kristijanhusak/vim-dadbod-completion' "Optional


call plug#end()
