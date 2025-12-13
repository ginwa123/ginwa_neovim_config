" Keybindings and mappings

" Diagnostic navigation
" ]e → next ERROR only
" [e → previous ERROR only
nnoremap <silent> ]e <cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR, float = {border = "rounded", focusable = false}})<CR>
nnoremap <silent> [e <cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR, float = {border = "rounded", focusable = false}})<CR>

" ]w -> Next WARNING only
" [w -> Previous WARNING only
nnoremap <silent> ]w <cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN, float = {border = "rounded", focusable = false}})<CR>
nnoremap <silent> [w <cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN, float = {border = "rounded", focusable = false}})<CR>

" ]h -> Next HINT only
" [h -> Previous HINT only
nnoremap <silent> ]h <cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.HINT, float = {border = "rounded", focusable = false}})<CR>
nnoremap <silent> [h <cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.HINT, float = {border = "rounded", focusable = false}})<CR>


" Neovimtree
nnoremap <leader>e <cmd>NvimTreeToggle toggle<CR>
" CORE LSP ACTIONS (C# with OmniSharp)
" Rename symbol (F2 like VS Code/Rider)
nnoremap <F2>     <cmd>lua vim.lsp.buf.rename()<CR>
" Find all references
nnoremap <leader>fr  <cmd>lua require('fzf-lua').lsp_references()<CR>
" FZF keybindings
" Files search
nnoremap <leader>ff <cmd>lua require('fzf-lua').files()<CR>
" Ripgrep search
nnoremap <leader>fgg <cmd>lua require('fzf-lua').live_grep({resume=true})<CR>
" Buffers
nnoremap <leader>fb <cmd>lua require('fzf-lua').buffers()<CR>
" Lines in current file
nnoremap <leader>fl <cmd>lua require('fzf-lua').lines()<CR>
" Git tracked files
nnoremap <leader>fgf <cmd>lua require('fzf-lua').git_files()<CR>
" Git status files (modified)
nnoremap <leader>fgs <cmd>lua require('fzf-lua').git_status()<CR>
" History (commands/files/search)
nnoremap <leader>fh <cmd>lua require('fzf-lua').oldfiles()<CR>
" Document symbol list
nnoremap <leader>fwd <cmd>lua require('fzf-lua').lsp_document_symbols()<CR>
" Error list
nnoremap <silent> <leader>fe <cmd>lua vim.diagnostic.setqflist({severity = vim.diagnostic.severity.ERROR})<CR><cmd>copen<CR>
" Code action / quick fix (Ctrl+. in VS Code)
nnoremap <leader>ca <cmd>lua require('fzf-lua').lsp_code_actions()<CR>
vnoremap <leader>ca <cmd>lua require('fzf-lua').lsp_code_actions()<CR>
" Hover / show documentation (K or <leader>k)
nnoremap K         <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>k <cmd>lua vim.lsp.buf.hover()<CR>
" gd → go to definition (exactly like VS Code now)
nnoremap <silent> gd <cmd>lua require('fzf-lua').lsp_definitions()<CR>
" gi → go to implementation
nnoremap gi        <cmd>lua require('fzf-lua').lsp_implementations()<CR>
" Go to type definition (e.g. from variable → class)
nnoremap gy        <cmd>lua require('fzf-lua').lsp_type_definitions()<CR>
" Format entire file (OmniSharp + csharpier or built-inp
nnoremap <leader>faf <cmd>lua vim.lsp.buf.format({async = true})<CR>
" Formate selection
vnoremap <leader>faf <cmd>lua vim.lsp.buf.format({async = true})<CR>

" Error diagnostics using fzf
nnoremap <leader>fe <cmd>lua require('fzf-lua').diagnostics_workspace({severity_limit = "ERROR"})<CR>
" Debug keybindings
" bl Open list break point using fzf lua,
nnoremap <leader>bl <cmd>lua require('fzf-lua').dap_breakpoints()<CR>
" vl Open list variable debug using fzf lua,
nnoremap <silent> <leader>vl <cmd>lua require('fzf-lua').dap_variables()<CR>
nnoremap <silent> vl <cmd>lua require('fzf-lua').dap_variables()<CR>
" Open a grug-far to find and replace, using leader gar
nnoremap <silent> <leader>gar <cmd>lua require('grug-far').open()<CR>
" Debug keybindings
nnoremap <F5> <cmd>lua require('dap').continue()<CR>
nnoremap <F10> <cmd>lua require('dap').step_over()<CR>
nnoremap <F11> <cmd>lua require('dap').step_into()<CR>
nnoremap <F12> <cmd>lua require('dap').step_out()<CR>
"nnoremap <leader>b <cmd>lua require('dap').toggle_breakpoint()<CR>
"nnoremap <leader>B <cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
""nnoremap <leader>bc <cmd>lua require('dap').clear_breakpoints()<CR>
nnoremap gb <cmd>lua require('dap').toggle_breakpoint()<CR>
nnoremap <F6> <cmd>DapViewToggle<CR>
" Test keybindings
nnoremap <leader>tt <cmd>lua run_test_with_correct_cwd("nearest")<CR>
nnoremap <leader>tf <cmd>lua run_test_with_correct_cwd("file")<CR>
nnoremap <leader>tp <cmd>lua run_test_with_correct_cwd("project")<CR>
nnoremap <leader>ts <cmd>lua require("neotest").summary.toggle()<CR>
nnoremap <leader>to <cmd>lua require("neotest").output.open({ enter = true })<CR>
nnoremap <leader>tO <cmd>lua require("neotest").output_panel.toggle()<CR>
nnoremap <leader>td <cmd>lua vim.notify("Project root: " .. find_nearest_project_or_solution(), vim.log.levels.INFO)<CR>
" Undotree
nnoremap <leader>tu :UndotreeToggle<CR>

" leap jump
nmap f <Plug>(leap)
xmap f <Plug>(leap)
omap f <Plug>(leap)

nmap F <Plug>(leap-from-window)


" Map back/forward keys to jump list navigation
" Now map F13/F14 to Ctrl+O/Ctrl+I
nnoremap <F13> <C-o>
nnoremap <F14> <C-i>


