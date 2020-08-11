call plug#begin(stdpath('data') . '/plugged')
" Plug 'akinsho/nvim-bufferline.lua'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'rakr/vim-one' " alternative one dark with a light theme
Plug 'rhysd/conflict-marker.vim'
call plug#end()

set background=dark
set termguicolors
colorscheme one

" lua require'bufferline'.setup()
nmap <C-N> :LuaTreeToggle<CR>
let g:lua_tree_follow               = 1 " show selected file on open
