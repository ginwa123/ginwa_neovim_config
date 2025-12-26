" Basic Neovim settings
set termguicolors
" set background=dark
set clipboard=unnamedplus

" Colorscheme
colorscheme moonfly     " ← change to whatever you like
"colorscheme github_dark_high_contrast
" Change leader to space
let mapleader = ' '
" Line numbers
set number
"set relativenumber

" UI improvements
" set showmode=false
" set showcmd=false
set cmdheight=0
set laststatus=3

" Disable netrw for nvim-tree
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" Remap arrow keys to work with counts in normal mode
nnoremap <Up> k
nnoremap <Down> j
nnoremap <Left> h
nnoremap <Right> l

" Custom command for nvim-tree
command! Tree NvimTreeToggle

" === Neovide: Ctrl+Shift+V pastes inside fzf-lua prompt (Vimscript) ===
if exists('g:neovide')
" Normal and Visual mode: paste before cursor / over selection
  nnoremap <C-S-v> "+P
  vnoremap <C-S-v> "+P

  " Insert mode: paste at cursor position
  inoremap <C-S-v> <Esc>"+pA

  " Command-line mode (e.g. when typing :commands or /search)
  cnoremap <C-S-v> <C-r>+

  " Terminal mode (inside :terminal)
tnoremap <C-S-v> <C-\><C-n>"+pa

  " Optional: also make Ctrl+Shift+C copy to system clipboard
  nnoremap <C-S-c> "+y
  vnoremap <C-S-c> "+y
  inoremap <C-S-c> <Esc>"+yA

  augroup NeovideFzfPaste
    autocmd!
    autocmd FileType fzf tnoremap <buffer> <C-S-v> <C-\><C-n>"+pA
    " Optional fallback for insert mode inside fzf (rarely needed)
    autocmd FileType fzf inoremap <buffer> <C-S-v> <C-o>"+p<C-o>A
  augroup END


	  let g:neovide_scroll_animation_length = 0.05


	" === Neovide Transparency ===
	" Background opacity (0.0 = fully transparent, 1.0 = solid)
	
if exists('g:neovide')
  if has('win32') || has('win64')
    " Windows: disable transparency (not supported)
    let g:neovide_transparency = 1.0
  else
    " Linux / macOS
	let g:neovide_opacity = 0.80
  endif
endif


  " Zoom in
  nnoremap <C-=> :let g:neovide_scale_factor += 0.1<CR>

  " Zoom out
  nnoremap <C--> :let g:neovide_scale_factor -= 0.1<CR>

  " Reset zoom
  nnoremap <C-0> :let g:neovide_scale_factor = 1.0<CR>

	" Keep text fully opaque (important for readability)
	let g:neovide_background_color = "#000000"

	" Remove gradient so transparency is clean
	let g:neovide_background_top_color = "#00000000"
	let g:neovide_background_bottom_color = "#00000000"

	" === Floating windows blur ===
	" (Telescope, LSP popups, completion menu, etc.)
	let g:neovide_floating_blur_amount_x = 2.0
	let g:neovide_floating_blur_amount_y = 2.0

endif

let g:moonflyTransparent = 1
