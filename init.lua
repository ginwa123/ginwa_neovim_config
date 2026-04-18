-- ============================================
-- Plugin Management via vim.pack (Neovim 0.12)
-- ============================================

vim.pack.add({

  -- UI and Visual
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/sphamba/smear-cursor.nvim',
  'https://github.com/mbbill/undotree',
  -- 'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/nvim-mini/mini.icons',
  -- 'https://github.com/RRethy/vim-illuminate',

  -- Themes / Colorschemes
  'https://github.com/rebelot/kanagawa.nvim',
  'https://github.com/catppuccin/nvim',
  'https://github.com/bluz71/vim-moonfly-colors',
  'https://github.com/projekt0n/github-nvim-theme',
  'https://github.com/webhooked/kanso.nvim',
  -- 'https://github.com/morhetz/gruvbox',
  'https://github.com/uhs-robert/oasis.nvim',
  'https://github.com/sainnhe/gruvbox-material',
  'https://github.com/altercation/vim-colors-solarized',
  'https://github.com/ellisonleao/gruvbox.nvim',

  -- Navigation and Search
  'https://github.com/folke/which-key.nvim',
  'https://github.com/junegunn/fzf',
  'https://github.com/junegunn/fzf.vim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/MagicDuck/grug-far.nvim',
  'https://codeberg.org/andyg/leap.nvim',
  'https://github.com/s1n7ax/nvim-window-picker',
  'https://github.com/nvim-mini/mini.move',
  'https://github.com/andymass/vim-matchup',
  'https://github.com/stevearc/aerial.nvim',

  -- Git Integration
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/sindrets/diffview.nvim',

  -- LSP and Completion
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/saghen/blink.compat',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/Wansmer/symbol-usage.nvim',
  'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/stevearc/conform.nvim',
  -- 'https://github.com/seblyng/roslyn.nvim',

  -- elixir-tools pinned to stable tag
  { src = 'https://github.com/elixir-tools/elixir-tools.nvim', checkout = 'stable' },

  -- blink.cmp requires a Rust build step
  {
    src = 'https://github.com/saghen/blink.cmp',
  },

  -- AI and Code Assistance
  -- 'https://github.com/Exafunction/windsurf.nvim',
  'https://github.com/supermaven-inc/supermaven-nvim',

  -- Syntax and Treesitter
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = {
      post_checkout = function() vim.cmd('TSUpdate') end,
    },
  },
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  -- 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',

  -- Debugging
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/igorlfs/nvim-dap-view',

  -- Testing
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/antoinemadec/FixCursorHold.nvim',
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/Issafalcon/neotest-dotnet',

})

require('basic-settings')
require('keybindings')

for _, file in ipairs(vim.fn.globpath(vim.fn.stdpath('config') .. '/lua/plugins', '*.lua', false, true)) do
  local module = file:match('lua/plugins/(.+)%.lua$')
  require('plugins.' .. module)
end