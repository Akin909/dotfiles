"--------------------------------------------------------------------------------
"PLUGINS
"--------------------------------------------------------------------------------

"--------------------------------------------------------------------------------
" Plug Setup {{{1
"--------------------------------------------------------------------------------
" auto-install vim-plug
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
if has("nvim")
  if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup VimPlug
      au!
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif
  call plug#begin(stdpath('data') . '/plugged')
else
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup VimPlug
      au!
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif
  call plug#begin('~/.vim/plugged')
endif


function! Cond(cond, ...)
  let l:opts = get(a:000, 0, {})
  return a:cond ? l:opts : extend(l:opts, { 'on': [], 'for': [] })
endfunction

let g:testing_nvim_lsp = 0
"--------------------------------------------------------------------------------
" CORE {{{1
"--------------------------------------------------------------------------------
if g:testing_nvim_lsp
"--------------------------------------------------------------------------------
" Nvim LSP:  TOO EARLY
"--------------------------------------------------------------------------------
  Plug 'neovim/nvim-lsp'
  Plug 'haorenW1025/completion-nvim'
  Plug 'haorenW1025/diagnostic-nvim'
else
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
Plug 'ryanoasis/vim-devicons' , Cond(!has('gui_running'))
Plug 'airblade/vim-rooter'
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascriptreact', 'typescriptreact'] }
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
      \ | Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-startify'
Plug 'honza/vim-snippets'
" Plug 'kyazdani42/nvim-web-devicons' " for file icons
" Plug 'kyazdani42/nvim-tree.lua'
if exists('$TMUX')
  Plug 'christoomey/vim-tmux-navigator'
endif
"--------------------------------------------------------------------------------
" Utilities {{{1
"--------------------------------------------------------------------------------
Plug 'vimwiki/vimwiki'
Plug 'arecarn/vim-fold-cycle'
Plug 'dyng/ctrlsf.vim'
" https://github.com/iamcco/markdown-preview.nvim/issues/50
Plug 'iamcco/markdown-preview.nvim', {
      \ 'do': ':call mkdp#util#install()',
      \ 'for': ['markdown']
      \ }
Plug 'cohama/lexima.vim'
Plug 'mbbill/undotree', {'on': ['UndotreeToggle']} " undo plugin for vim
Plug 'chip/vim-fat-finger', {'on': [], 'for': []}
" We lazy load vim fat finger because it otherwise takes 80ms ie. the slowest
" thing to load blocking vim startup time
augroup Lazy_load_fat_fingers
    autocmd!
    autocmd CursorHold,CursorHoldI * call plug#load('vim-fat-finger')
          \ | autocmd! Lazy_load_fat_fingers
augroup end
Plug 'psliwka/vim-smoothie'
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'janko/vim-test', { 'on': ['TestFile', 'TestNearest', 'TestLatest'] }
Plug 'norcalli/nvim-colorizer.lua'
Plug 'dstein64/vim-win'
Plug 'AndrewRadev/tagalong.vim', {'for': [
      \ 'typescriptreact',
      \ 'javascriptreact',
      \ 'reason',
      \ 'html',
      \ 'typescript',
      \ 'javascript'
      \ ]}
Plug 'tweekmonster/startuptime.vim', { 'on': 'StartupTime' }
"--------------------------------------------------------------------------------
" TPOPE {{{1
"--------------------------------------------------------------------------------
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
"sets searchable path for filetypes like go so 'gf' works
Plug 'tpope/vim-apathy'
Plug 'tpope/vim-dadbod'
      \ | Plug 'kristijanhusak/vim-dadbod-ui', { 'on': ['DBUI', 'DBUIToggle'] }
"--------------------------------------------------------------------------------
" Syntax {{{1
"--------------------------------------------------------------------------------
Plug 'Yggdroot/indentLine'
" Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries', 'for': ['go'] }
Plug 'sheerun/vim-polyglot'
"--------------------------------------------------------------------------------
" Git {{{1
"--------------------------------------------------------------------------------
Plug 'tpope/vim-fugitive'
Plug 'sodapopcan/vim-twiggy'
Plug 'rhysd/conflict-marker.vim'
" FIXME currently breaks :Gblame functionality
" Plug 'tpope/vim-rhubarb'
"--------------------------------------------------------------------------------
" Text Objects {{{1
"--------------------------------------------------------------------------------
Plug 'AndrewRadev/switch.vim'
Plug 'AndrewRadev/splitjoin.vim'
""---------------------------------------------------------------------------//
" Deprecated: Word transposition mappings from in favour of the plugin below:
" http://superuser.com/questions/290360/how-to-switch-words-in-an-easy-manner-in-vim/290449#290449
""---------------------------------------------------------------------------//
Plug 'AndrewRadev/sideways.vim'
Plug 'bkad/CamelCaseMotion'
Plug 'tommcdo/vim-exchange'
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
      \ | Plug 'kana/vim-operator-user'
      \ | Plug 'glts/vim-textobj-comment'
      \ | Plug 'inside/vim-textobj-jsxattr'
"--------------------------------------------------------------------------------
" Search Tools {{{1
"--------------------------------------------------------------------------------
Plug 'junegunn/vim-peekaboo'
Plug 'kshenoy/vim-signature'
Plug 'junegunn/goyo.vim', { 'for':['vimwiki','markdown'] }
"--------------------------------------------------------------------------------
" Filetype Plugins {{{1
"--------------------------------------------------------------------------------
Plug 'mhinz/vim-crates', {'for': ['rust', 'toml']}
"--------------------------------------------------------------------------------
" Themes  {{{1
"--------------------------------------------------------------------------------
" NOTE: vim-one has a MUCH better startup time than onedark
Plug 'rakr/vim-one' " alternative one dark with a light theme
" Plug 'joshdick/onedark.vim' " More actively maintained that vim-one
"--------------------------------------------------------------------------------
" Alternatives colorschemes {{{2
"--------------------------------------------------------------------------------
" Plug 'haishanh/night-owl.vim'
" Plug 'patstockwell/vim-monokai-tasty'

Plug 'rhysd/try-colorscheme.vim', {'on':'TryColorscheme'}

"--------------------------------------------------------------------------------
" Personal plugins  {{{1
"--------------------------------------------------------------------------------
if has('nvim')
  " Plug '~/Desktop/Coding/nvim-bufferline.lua'
  Plug 'Akin909/nvim-bufferline.lua'
else
  " vim-devicons must be loaded before vim buffet in order for icons to be used
  Plug 'bagrat/vim-buffet'
endif

call plug#end()
if has('patch-7.4.1649') && !has('nvim') " NeoVim loads matchit by default
  packadd! matchit
endif

" Disable unnecessary default plugins
let g:loaded_gzip              = 1
let g:loaded_tar               = 1
let g:loaded_tarPlugin         = 1
let g:loaded_zip               = 1
let g:loaded_zipPlugin         = 1
let g:loaded_rrhelper          = 1

" SOURCE: https://github.com/junegunn/vim-plug/pull/875
" Check if the files is in the plugs map but also IMPORTANTLY
" that it is in the runtimepath
function PluginLoaded(plugin_name) abort
  return has_key(g:plugs, a:plugin_name) && stridx(&rtp, g:plugs[a:plugin_name].dir)
endfunction
" vim:foldmethod=marker
