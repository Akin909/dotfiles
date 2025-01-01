local o, opt, fn, icons = vim.o, vim.opt, vim.fn, as.ui.icons
-----------------------------------------------------------------------------//
-- Message output on vim actions {{{1
-----------------------------------------------------------------------------//
opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  F = true, -- Don't give file info when editing a file, NOTE: this breaks autocommand messages
  s = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
}
-----------------------------------------------------------------------------//
-- Timings {{{1
-----------------------------------------------------------------------------//
o.updatetime = 300
o.timeout = true
o.timeoutlen = 500
o.ttimeoutlen = 10
-----------------------------------------------------------------------------//
-- Window splitting and buffers {{{1
-----------------------------------------------------------------------------//
o.splitkeep = 'screen'
o.splitbelow = true
o.splitright = true
o.eadirection = 'hor'
-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
o.switchbuf = 'useopen,uselast'
opt.fillchars = {
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = ' ', -- alternatives: ‾ ─
  fold = '─',
  foldopen = '▽', -- '▼'
  foldclose = '▷', -- '▶'
  foldsep = ' ',
}
-----------------------------------------------------------------------------//
-- Diff {{{1
-----------------------------------------------------------------------------//
-- Use in vertical diff mode, blank lines to keep sides aligned, Ignore whitespace changes
opt.diffopt = opt.diffopt
  + {
    'vertical',
    'iwhite',
    'hiddenoff',
    'foldcolumn:0',
    'context:4',
    'algorithm:histogram',
    'indent-heuristic',
    'linematch:60',
  }
-----------------------------------------------------------------------------//
-- Format Options {{{1
-----------------------------------------------------------------------------//
opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}
-----------------------------------------------------------------------------//
-- Folds {{{1
-----------------------------------------------------------------------------//
opt.foldlevelstart = 3
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldtext = ''
-----------------------------------------------------------------------------//
-- Grepprg {{{1
-----------------------------------------------------------------------------//
-- Use faster grep alternatives if possible
if as and not as.falsy(fn.executable('rg')) then
  vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
elseif as and not as.falsy(fn.executable('ag')) then
  vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end
-----------------------------------------------------------------------------//
-- Wild and file globbing stuff in command mode {{{1
-----------------------------------------------------------------------------//
o.wildcharm = ('\t'):byte()
o.wildmenu = false -- Turn (on/)off the native commandline completion menu
o.messagesopt = 'wait:1500,history:10000'
o.wildmode = 'full' -- 'list:full' -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true -- Ignore case when completing file names and directories
opt.wildignore = {
  '*.o',
  '*.obj',
  '*.dll',
  '*.jar',
  '*.pyc',
  '*.rbc',
  '*.class',
  '*.gif',
  '*.ico',
  '*.jpg',
  '*.jpeg',
  '*.png',
  '*.avi',
  '*.wav',
  '*.swp',
  '.lock',
  '.DS_Store',
  'tags.lock',
}
opt.wildoptions = { 'pum', 'fuzzy' }
o.pumblend = 0 -- Make popup window translucent
-----------------------------------------------------------------------------//
-- Display {{{1
-----------------------------------------------------------------------------//
o.colorcolumn = '+1'
o.conceallevel = 2
o.breakindentopt = 'sbr'
o.linebreak = true -- lines wrap at words rather than random characters
o.signcolumn = 'yes:1'
o.ruler = false
o.cmdheight = 0
o.showbreak = [[↳ ]] -- Options include -> '…', '↳ ', '→','↪ '
-----------------------------------------------------------------------------//
-- List chars {{{1
-----------------------------------------------------------------------------//
o.list = true -- invisible chars
opt.listchars = {
  eol = nil,
  tab = '  ', -- Alternatives: '▷▷',
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
}
-----------------------------------------------------------------------------//
-- Indentation
-----------------------------------------------------------------------------//
o.wrap = false
o.wrapmargin = 2
o.textwidth = 80
o.autoindent = true
o.shiftround = true
o.expandtab = true
o.shiftwidth = 2
-----------------------------------------------------------------------------//
o.pumheight = 15
o.confirm = true -- make vim prompt me to save before doing destructive things
opt.completeopt = { 'menuone' }
o.hlsearch = true
o.autowriteall = true -- automatically :write before running commands and changing files
opt.clipboard = { 'unnamedplus' }
o.laststatus = 3
o.termguicolors = true
o.guifont = 'CartographCF Nerd Font Mono:h14,codicon'
-----------------------------------------------------------------------------//
-- Emoji {{{1
-----------------------------------------------------------------------------//
-- emoji is true by default but makes (n)vim treat all emoji as double width
-- which breaks rendering so we turn this off.
-- CREDIT: https://www.youtube.com/watch?v=F91VWOelFNE
o.emoji = false
-----------------------------------------------------------------------------//
-- Cursor {{{1
-----------------------------------------------------------------------------//
-- This is from the help docs, it enables mode shapes, "Cursor" highlight, and blinking
opt.guicursor = {
  'n-v-c-sm:block-Cursor',
  'i-ci-ve:ver25-iCursor',
  'r-cr-o:hor20-Cursor',
  'a:blinkon0',
}
opt.cursorlineopt = { 'both' }
-----------------------------------------------------------------------------//
-- Title {{{1
-----------------------------------------------------------------------------//
function as.modified_icon() return vim.bo.modified and icons.misc.circle or '' end
o.titlestring = '%{fnamemodify(getcwd(), ":t")}%( %{v:lua.as.modified_icon()}%)'
o.titleold = fn.fnamemodify(vim.uv.os_getenv('SHELL'), ':t') or ''
o.title = true
o.titlelen = 70
-----------------------------------------------------------------------------//
-- Utilities {{{1
-----------------------------------------------------------------------------//
o.showmode = false
-- NOTE: Don't remember
-- * help files since that will error if they are from a lazy loaded plugin
-- * folds since they are created dynamically and might be missing on startup
opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'winpos',
  'winsize',
  'help',
  'tabpages',
  'terminal',
  'folds',
}
opt.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
o.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
-----------------------------------------------------------------------------//
-- Jumplist
-----------------------------------------------------------------------------//
opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack
-------------------------------------------------------------------------------
-- BACKUP AND SWAPS {{{
-------------------------------------------------------------------------------
o.backup = false
o.undofile = true
o.swapfile = false
--}}}
-----------------------------------------------------------------------------//
-- Match and search {{{1
-----------------------------------------------------------------------------//
o.ignorecase = true
o.smartcase = true
o.wrapscan = true -- Searches wrap around the end of the file
o.scrolloff = 9
o.sidescrolloff = 10
o.sidescroll = 1
-----------------------------------------------------------------------------//
-- Spelling {{{1
-----------------------------------------------------------------------------//
opt.spellsuggest:prepend({ 12 })
opt.spelloptions:append({ 'camel', 'noplainbuffer' })
opt.spellcapcheck = '' -- don't check for capital letters at start of sentence
-----------------------------------------------------------------------------//
-- Mouse {{{1
-----------------------------------------------------------------------------//
o.mousefocus = true
o.mousemoveevent = true
opt.mousescroll = { 'ver:1', 'hor:6' }
-----------------------------------------------------------------------------//
-- Allow project local vimrc files example, .nvim.lua or .nvimrc see :h exrc
o.exrc = as.has('nvim-0.9')
-- vim:foldmethod=marker
