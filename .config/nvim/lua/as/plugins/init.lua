local utils = require('as.utils.plugins')

local dev = utils.dev
local conf = utils.conf
local use_local = utils.use_local
local packer_notify = utils.packer_notify

local fn = vim.fn
local fmt = string.format

local PACKER_COMPILED_PATH = fn.stdpath('cache') .. '/packer/packer_compiled.lua'

---Some plugins are not safe to be reloaded because their setup functions
---and are not idempotent. This wraps the setup calls of such plugins
---@param func fun()
function as.block_reload(func)
  if vim.g.packer_compiled_loaded then
    return
  end
  func()
end

-----------------------------------------------------------------------------//
-- Bootstrap Packer {{{3
-----------------------------------------------------------------------------//
utils.bootstrap_packer()
----------------------------------------------------------------------------- }}}1
-- cfilter plugin allows filtering down an existing quickfix list
vim.cmd('packadd! cfilter')

as.safe_require('impatient')

local packer = require('packer')
--- NOTE "use" functions cannot call *upvalues* i.e. the functions
--- passed to setup or config etc. cannot reference aliased functions
--- or local variables
packer.startup({
  function(use, use_rocks)
    -- FIXME: this no longer loads the local plugin since the compiled file now
    -- loads packer.nvim so the local alias(local-packer) does not work
    use_local({ 'wbthomason/packer.nvim', local_path = 'contributing', opt = true })
    -----------------------------------------------------------------------------//
    -- Core {{{3
    -----------------------------------------------------------------------------//
    use_rocks('penlight')

    -- TODO: this fixes a bug in neovim core that prevents "CursorHold" from working
    -- hopefully one day when this issue is fixed this can be removed
    -- @see: https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- THE LIBRARY
    use('nvim-lua/plenary.nvim')

    use({
      'ahmedkhalf/project.nvim',
      config = function()
        require('project_nvim').setup({
          ignore_lsp = { 'null-ls' },
          patterns = { '.git' },
        })
      end,
    })

    use({
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      module_pattern = 'telescope.*',
      setup = conf('telescope').setup,
      config = conf('telescope').config,
      requires = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension('fzf')
          end,
        },
        {
          'nvim-telescope/telescope-frecency.nvim',
          after = 'telescope.nvim',
          requires = 'tami5/sqlite.lua',
        },
        { 'Zane-/howdoi.nvim' },
        {
          'nvim-telescope/telescope-smart-history.nvim',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension('smart_history')
          end,
        },
      },
    })

    use({ 'ilAYAli/scMRU.nvim', module = 'mru' })

    use('kyazdani42/nvim-web-devicons')

    use({ 'folke/which-key.nvim', config = conf('whichkey') })

    use({
      'rmagatti/auto-session',
      config = function()
        require('auto-session').setup({
          log_level = 'error',
          auto_session_root_dir = ('%s/session/auto/'):format(vim.fn.stdpath('data')),
          auto_session_use_git_branch = false, -- This cause inconsistent results
        })
      end,
    })

    use({
      'knubie/vim-kitty-navigator',
      run = 'cp ./*.py ~/.config/kitty/',
      cond = function()
        return not vim.env.TMUX
      end,
    })

    use({ 'lukas-reineke/indent-blankline.nvim', config = conf('indentline') })

    use({
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v2.x',
      config = conf('neo-tree'),
      keys = { '<C-N>' },
      cmd = { 'NeoTree' },
      requires = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'kyazdani42/nvim-web-devicons',
        { 's1n7ax/nvim-window-picker', tag = '1.*', config = conf('window-picker') },
      },
    })
    -- }}}
    -----------------------------------------------------------------------------//
    -- LSP,Completion & Debugger {{{1
    -----------------------------------------------------------------------------//
    use({
      {
        'williamboman/nvim-lsp-installer',
        event = 'BufRead',
        config = function()
          require('nvim-lsp-installer').setup({
            automatic_installation = true,
            ui = { border = as.style.current.border },
          })
        end,
      },
      -- lspconfig is abominably slow to load and if loaded on BufReadPre seems to interact with nvim-treesitter
      {
        'neovim/nvim-lspconfig',
        after = 'nvim-lsp-installer',
        config = conf('lspconfig'),
      },
    })

    use({
      'smjonas/inc-rename.nvim',
      config = function()
        require('inc_rename').setup({ hl_group = 'Visual' })
        as.nnoremap('<leader>ri', function()
          return ':IncRename ' .. vim.fn.expand('<cword>')
        end, { expr = true, silent = false, desc = 'lsp: incremental rename' })
      end,
    })

    use({
      'narutoxy/dim.lua',
      requires = { 'nvim-treesitter/nvim-treesitter', 'neovim/nvim-lspconfig' },
      config = function()
        require('dim').setup({ disable_lsp_decorations = true })
      end,
    })

    use({
      'kosayoda/nvim-lightbulb',
      config = function()
        local lightbulb = require('nvim-lightbulb')
        lightbulb.setup({
          ignore = { 'null-ls' },
          sign = { enabled = false },
          float = { enabled = true, win_opts = { border = 'none' } },
          autocmd = {
            enabled = true,
          },
        })
      end,
    })

    use({
      'jose-elias-alvarez/null-ls.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = conf('null-ls'),
    })

    use({
      'ray-x/lsp_signature.nvim',
      config = function()
        require('lsp_signature').setup({
          bind = true,
          fix_pos = false,
          auto_close_after = 15, -- close after 15 seconds
          hint_enable = false,
          handler_opts = { border = as.style.current.border },
        })
      end,
    })

    use({
      'hrsh7th/nvim-cmp',
      module = 'cmp',
      event = 'InsertEnter',
      config = conf('cmp'),
      requires = {
        { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-lspconfig' },
        { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
        { 'f3fora/cmp-spell', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'uga-rosa/cmp-dictionary', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
        { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
        { 'dmitmel/cmp-cmdline-history', after = 'nvim-cmp' },
        {
          'petertriho/cmp-git',
          after = 'nvim-cmp',
          config = function()
            require('cmp_git').setup({ filetypes = { 'gitcommit', 'NeogitCommitMessage' } })
          end,
        },
      },
    })

    -- Use <Tab> to escape from pairs such as ""|''|() etc.
    use({
      'abecodes/tabout.nvim',
      wants = { 'nvim-treesitter' },
      after = { 'nvim-cmp' },
      config = function()
        require('tabout').setup({
          completion = false,
          ignore_beginning = false,
        })
      end,
    })

    -- }}}
    -----------------------------------------------------------------------------//
    -- Testing and Debugging {{{1
    -----------------------------------------------------------------------------//
    use({
      'vim-test/vim-test',
      config = conf('vim-test').config,
    })

    use({
      'rcarriga/neotest',
      config = conf('neotest'),
      requires = {
        'rcarriga/neotest-plenary',
        'rcarriga/neotest-vim-test',
        'nvim-lua/plenary.nvim',
        dev('personal/neotest-go'),
        'nvim-treesitter/nvim-treesitter',
        'antoinemadec/FixCursorHold.nvim',
      },
    })

    use({
      'mfussenegger/nvim-dap',
      module = 'dap',
      setup = conf('dap').setup,
      config = conf('dap').config,
      requires = {
        {
          'rcarriga/nvim-dap-ui',
          after = 'nvim-dap',
          config = conf('dapui'),
        },
        {
          'theHamsta/nvim-dap-virtual-text',
          after = 'nvim-dap',
          config = function()
            require('nvim-dap-virtual-text').setup({ all_frames = true })
          end,
        },
      },
    })

    use({ 'jbyuki/one-small-step-for-vimkind', requires = 'nvim-dap' })
    use('folke/lua-dev.nvim')

    --}}}
    -----------------------------------------------------------------------------//
    -- UI
    -----------------------------------------------------------------------------//
    use({
      'lewis6991/satellite.nvim',
      config = function()
        require('satellite').setup({
          handlers = {
            gitsigns = {
              enable = false,
            },
            marks = {
              enable = false,
            },
          },
          excluded_filetypes = {
            'packer',
            'neo-tree',
            'norg',
            'neo-tree-popup',
            'dapui_scopes',
            'dapui_stacks',
          },
        })
      end,
    })

    -- NOTE: Defer loading till telescope is loaded this
    -- as it implicitly loads telescope so needs to be delayed
    use({ 'stevearc/dressing.nvim', after = 'telescope.nvim', config = conf('dressing') })

    --------------------------------------------------------------------------------
    -- Utilities {{{1
    --------------------------------------------------------------------------------
    use('nanotee/luv-vimdocs')
    use('milisims/nvim-luaref')

    -- FIXME: https://github.com/L3MON4D3/LuaSnip/issues/129
    -- causes formatting bugs on save when update events are TextChanged{I}
    use({
      'L3MON4D3/LuaSnip',
      event = 'InsertEnter',
      module = 'luasnip',
      requires = 'rafamadriz/friendly-snippets',
      config = conf('luasnip'),
    })

    use({
      'AckslD/nvim-neoclip.lua',
      config = function()
        require('neoclip').setup({
          enable_persistent_history = true,
          keys = {
            telescope = {
              i = { select = '<c-p>', paste = '<CR>', paste_behind = '<c-k>' },
              n = { select = 'p', paste = '<CR>', paste_behind = 'P' },
            },
          },
        })
        as.nnoremap('<localleader>p', function()
          require('telescope').extensions.neoclip.default(as.telescope.dropdown())
        end, 'neoclip: open yank history')
      end,
    })

    use({
      'folke/todo-comments.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = function()
        as.block_reload(function()
          require('todo-comments').setup({
            highlight = {
              exclude = { 'org', 'orgagenda', 'vimwiki', 'markdown' },
            },
          })
          as.nnoremap('<leader>lt', '<Cmd>TodoTrouble<CR>', 'trouble: todos')
        end)
      end,
    })

    use({
      'github/copilot.vim',
      config = function()
        vim.g.copilot_no_tab_map = true
        as.imap('<Plug>(as-copilot-accept)', "copilot#Accept('<Tab>')", { expr = true })
        as.inoremap('<M-]>', '<Plug>(copilot-next)')
        as.inoremap('<M-[>', '<Plug>(copilot-previous)')
        as.inoremap('<C-\\>', '<Cmd>vertical Copilot panel<CR>')

        vim.g.copilot_filetypes = {
          ['*'] = true,
          gitcommit = false,
          NeogitCommitMessage = false,
          DressingInput = false,
          TelescopePrompt = false,
          ['neo-tree-popup'] = false,
        }
        require('as.highlights').plugin('copilot', { CopilotSuggestion = { link = 'Comment' } })
      end,
    })

    use({
      'simeji/winresizer',
      setup = function()
        vim.g.winresizer_start_key = '<leader>w'
      end,
    })

    use({
      'klen/nvim-config-local',
      config = function()
        require('config-local').setup({
          config_files = { '.localrc.lua', '.vimrc', '.vimrc.lua' },
        })
      end,
    })

    -- prevent select and visual mode from overwriting the clipboard
    use({
      'kevinhwang91/nvim-hclipboard',
      event = 'InsertCharPre',
      config = function()
        require('hclipboard').start()
      end,
    })

    use({ 'chentoast/marks.nvim', config = conf('marks') })

    use({ 'monaqa/dial.nvim', config = conf('dial') })

    use({
      'jghauser/fold-cycle.nvim',
      config = function()
        require('fold-cycle').setup()
        as.nnoremap('<BS>', function()
          require('fold-cycle').open()
        end)
      end,
    })

    use({
      'rainbowhxch/beacon.nvim',
      config = function()
        require('as.highlights').plugin('beacon', {
          Beacon = { link = 'Cursor' },
        })
        local beacon = require('beacon')
        beacon.setup({
          minimal_jump = 20,
          ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
          ignore_filetypes = {
            'neo-tree',
            'qf',
            'NeogitCommitMessage',
            'NeogitPopup',
            'NeogitStatus',
            'packer',
            'trouble',
          },
        })
        as.augroup('BeaconCmds', {
          {
            event = 'BufReadPre',
            pattern = '*.norg',
            command = function()
              beacon.beacon_off()
            end,
          },
        })
      end,
    })

    use({
      'mfussenegger/nvim-treehopper',
      config = function()
        as.augroup('TreehopperMaps', {
          {
            event = 'FileType',
            command = function(args)
              -- FIXME: this issue should be handled inside the plugin rather than manually
              local langs = require('nvim-treesitter.parsers').available_parsers()
              if vim.tbl_contains(langs, vim.bo[args.buf].filetype) then
                as.omap('u', ":<C-U>lua require('tsht').nodes()<CR>", { buffer = args.buf })
                as.vnoremap('u', ":lua require('tsht').nodes()<CR>", { buffer = args.buf })
              end
            end,
          },
        })
      end,
    })

    use({
      'windwp/nvim-autopairs',
      after = 'nvim-cmp',
      config = function()
        require('nvim-autopairs').setup({
          close_triple_quotes = true,
          check_ts = true,
          ts_config = {
            lua = { 'string' },
            dart = { 'string' },
            javascript = { 'template_string' },
          },
          fast_wrap = {
            map = '<c-e>',
          },
        })
      end,
    })

    use({
      'declancm/cinnamon.nvim', -- NOTE: alternative: 'karb94/neoscroll.nvim'
      config = function()
        require('cinnamon').setup({
          extra_keymaps = true,
          scroll_limit = 50,
          default_delay = 5,
        })
      end,
    })

    use({
      'mg979/vim-visual-multi',
      config = function()
        vim.g.VM_highlight_matches = 'underline'
        vim.g.VM_theme = 'codedark'
        vim.g.VM_maps = {
          ['Find Under'] = '<C-e>',
          ['Find Subword Under'] = '<C-e>',
          ['Select Cursor Down'] = '\\j',
          ['Select Cursor Up'] = '\\k',
        }
      end,
    })

    use({
      'itchyny/vim-highlighturl',
      config = function()
        vim.g.highlighturl_guifg = require('as.highlights').get_hl('URL', 'fg')
      end,
    })

    use({
      'danymat/neogen',
      requires = 'nvim-treesitter/nvim-treesitter',
      module = 'neogen',
      setup = function()
        as.nnoremap('<localleader>nc', require('neogen').generate, 'comment: generate')
      end,
      config = function()
        require('neogen').setup({ snippet_engine = 'luasnip' })
      end,
    })

    use({
      'j-hui/fidget.nvim',
      local_path = 'contributing',
      config = function()
        require('fidget').setup({
          text = { spinner = 'moon' },
        })
      end,
    })

    use({
      'rcarriga/nvim-notify',
      cond = utils.not_headless, -- TODO: causes blocking output in headless mode
      config = as.block_reload(conf('notify')),
    })

    use({
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      setup = function()
        as.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle')
      end,
      config = function()
        vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
        vim.g.undotree_SetFocusWhenToggle = 1
      end,
    })

    use({
      'iamcco/markdown-preview.nvim',
      run = function()
        vim.fn['mkdp#util#install']()
      end,
      ft = { 'markdown' },
      config = function()
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
      end,
    })

    use({
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup({ '*', '!dart' }, {
          RGB = false,
          mode = 'background',
        })
      end,
    })

    use({
      'moll/vim-bbye',
      config = function()
        as.nnoremap('<leader>qq', '<Cmd>Bwipeout<CR>', 'bbye: quit')
      end,
    })
    -----------------------------------------------------------------------------//
    -- Quickfix
    -----------------------------------------------------------------------------//
    use({
      'https://gitlab.com/yorickpeterse/nvim-pqf',
      event = 'BufReadPre',
      config = function()
        require('as.highlights').plugin('pqf', { qfPosition = { link = 'Tag' } })
        require('pqf').setup({})
      end,
    })

    use({
      'kevinhwang91/nvim-bqf',
      ft = 'qf',
      config = function()
        require('as.highlights').plugin('bqf', { BqfPreviewBorder = { foreground = 'Gray' } })
      end,
    })
    --------------------------------------------------------------------------------
    -- Knowledge and task management {{{1
    --------------------------------------------------------------------------------
    use({
      'vhyrro/neorg',
      requires = { 'vhyrro/neorg-telescope', 'max397574/neorg-kanban' },
      config = conf('neorg'),
    })

    use({
      'lukas-reineke/headlines.nvim',
      setup = conf('headlines').setup,
      config = conf('headlines').config,
    })
    -- }}}
    --------------------------------------------------------------------------------
    -- Profiling & Startup {{{1
    --------------------------------------------------------------------------------
    -- TODO: this plugin will be redundant once https://github.com/neovim/neovim/pull/15436 is merged
    use('lewis6991/impatient.nvim')
    use({
      'dstein64/vim-startuptime',
      cmd = 'StartupTime',
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { '+let g:auto_session_enabled = 0' }
      end,
    })
    -- }}}
    --------------------------------------------------------------------------------
    -- TPOPE {{{1
    --------------------------------------------------------------------------------
    use({
      'kristijanhusak/vim-dadbod-ui',
      requires = 'tpope/vim-dadbod',
      cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection' },
      setup = function()
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_database_icon = 1
        as.nnoremap('<leader>db', '<cmd>DBUIToggle<CR>', 'dadbod: toggle')
      end,
    })
    use('tpope/vim-eunuch')
    use('tpope/vim-sleuth')
    use('tpope/vim-repeat')

    use({
      'johmsalas/text-case.nvim',
      config = function()
        require('textcase').setup()
        as.nnoremap('<localleader>[', ':Subs/<C-R><C-W>//<LEFT>', { silent = false })
        as.nnoremap('<localleader>]', ':%Subs/<C-r><C-w>//c<left><left>', { silent = false })
        as.xnoremap('<localleader>[', [["zy:%Subs/<C-r><C-o>"//c<left><left>]], { silent = false })
      end,
    })
    -- sets searchable path for filetypes like go so 'gf' works
    use('tpope/vim-apathy')
    use({ 'tpope/vim-projectionist', config = conf('vim-projectionist') })
    use({
      'tpope/vim-surround',
      config = function()
        as.xmap('s', '<Plug>VSurround')
        as.xmap('s', '<Plug>VSurround')
      end,
    })
    -- }}}
    -----------------------------------------------------------------------------//
    -- Filetype Plugins {{{1
    -----------------------------------------------------------------------------//
    use_local({
      'akinsho/flutter-tools.nvim',
      requires = { 'nvim-dap', 'plenary.nvim' },
      local_path = 'personal',
      config = conf('flutter-tools'),
    })

    use({ 'ray-x/go.nvim', ft = 'go', config = conf('go') })
    use('nanotee/sqls.nvim')

    use({
      'tami5/xbase',
      ft = { 'swift' },
      run = 'make install',
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
      },
    })

    use('dart-lang/dart-vim-plugin')
    use('mtdl9/vim-log-highlighting')
    use('fladson/vim-kitty')
    use({
      'SmiteshP/nvim-gps',
      requires = 'nvim-treesitter/nvim-treesitter',
      config = function()
        local icons = as.style.lsp.codicons
        local types = as.style.icons.type
        require('nvim-gps').setup({
          icons = {
            ['class-name'] = icons.Class,
            ['function-name'] = icons.Function,
            ['method-name'] = icons.Method,
            ['container-name'] = icons.Module,
            ['tag-name'] = icons.Field,
            ['array-name'] = icons.Value,
            ['object-name'] = icons.Value,
            ['null-name'] = icons.Null,
            ['boolean-name'] = icons.Keyword,
            ['number-name'] = icons.Value,
            ['string-name'] = icons.Text,
            ['mapping-name'] = types.object,
            ['sequence-name'] = types.array,
            ['integer-name'] = types.number,
            ['float-name'] = types.float,
          },
        })
      end,
    })
    -- }}}
    --------------------------------------------------------------------------------
    -- Syntax {{{1
    --------------------------------------------------------------------------------
    use({
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf('treesitter'),
      local_path = 'contributing',
    })

    use({ 'p00f/nvim-ts-rainbow' })
    use({ 'nvim-treesitter/nvim-treesitter-textobjects' })
    use({
      'nvim-treesitter/playground',
      cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
      setup = function()
        as.nnoremap(
          '<leader>E',
          '<Cmd>TSHighlightCapturesUnderCursor<CR>',
          'treesitter: highlight cursor group'
        )
      end,
    })

    use({
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        local hl = require('as.highlights')
        local norm_bg = hl.get_hl('Normal', 'bg')
        local dim = hl.alter_color(norm_bg, 12)
        local dimmer = hl.alter_color(norm_bg, 8)
        hl.plugin('treesitter-context', {
          ContextBorder = { foreground = dim, background = dimmer },
          TreesitterContext = { inherit = 'Normal', background = dimmer },
          TreesitterContextLineNumber = { inherit = 'LineNr', background = dimmer },
        })
        require('treesitter-context').setup({
          multiline_threshold = 4,
          separator = { '▁', 'ContextBorder' },
        })
      end,
    })

    use({
      'lewis6991/spellsitter.nvim',
      config = function()
        require('spellsitter').setup({ enable = true })
      end,
    })

    use({ 'psliwka/vim-dirtytalk', run = ':DirtytalkUpdate' })
    ---}}}
    --------------------------------------------------------------------------------
    -- Git {{{1
    --------------------------------------------------------------------------------
    use({
      'ruifm/gitlinker.nvim',
      requires = 'plenary.nvim',
      keys = { '<localleader>gu', '<localleader>go' },
      setup = function()
        require('which-key').register(
          { gu = 'gitlinker: get line url', go = 'gitlinker: open repo url' },
          { prefix = '<localleader>' }
        )
      end,
      config = function()
        local linker = require('gitlinker')
        linker.setup({ mappings = '<localleader>gu' })
        as.nnoremap('<localleader>go', function()
          linker.get_repo_url({ action_callback = require('gitlinker.actions').open_in_browser })
        end, 'gitlinker: open in browser')
      end,
    })

    use({ 'lewis6991/gitsigns.nvim', event = 'CursorHold', config = conf('gitsigns') })

    use({
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      keys = { '<localleader>gs', '<localleader>gl', '<localleader>gp' },
      requires = 'plenary.nvim',
      setup = conf('neogit').setup,
      config = conf('neogit').config,
    })

    use({
      'ldelossa/gh.nvim',
      requires = 'ldelossa/litee.nvim',
      cmd = { 'GHOpenPR' },
      config = conf('gh'),
    })

    use({
      'sindrets/diffview.nvim',
      cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
      module = 'diffview',
      setup = function()
        as.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>', 'diffview: diff HEAD')
        as.nnoremap('<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', 'diffview: file history')
      end,
      config = function()
        require('diffview').setup({
          default_args = { DiffviewOpen = { 'origin/HEAD' } },
          hooks = {
            diff_buf_read = function()
              vim.opt_local.wrap = false
              vim.opt_local.list = false
              vim.opt_local.colorcolumn = ''
            end,
          },
          enhanced_diff_hl = true,
          keymaps = {
            view = { q = '<Cmd>DiffviewClose<CR>' },
            file_panel = { q = '<Cmd>DiffviewClose<CR>' },
            file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
          },
        })
      end,
    })

    use({
      'rlch/github-notifications.nvim',
      -- don't load this plugin if the gh cli is not installed
      requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
      cond = function()
        return as.executable('gh')
      end,
    })
    ---}}}
    --------------------------------------------------------------------------------
    -- Text Objects {{{1
    --------------------------------------------------------------------------------
    use({
      'AckslD/nvim-trevJ.lua',
      module = 'trevj',
      setup = function()
        as.nnoremap('gS', function()
          require('trevj').format_at_cursor()
        end, { desc = 'splitjoin: split' })
      end,
      config = function()
        require('trevj').setup()
      end,
    })

    use({ 'Matt-A-Bennett/vim-surround-funk', config = conf('surround-funk') })

    use('chaoren/vim-wordmotion')

    use({
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end,
    })

    use({
      'gbprod/substitute.nvim',
      config = function()
        require('substitute').setup()
        as.nnoremap('S', function()
          require('substitute').operator()
        end)
        as.xnoremap('S', function()
          require('substitute').visual()
        end)
        as.nnoremap('X', function()
          require('substitute.exchange').operator()
        end)
        as.xnoremap('X', function()
          require('substitute.exchange').visual()
        end)
        as.nnoremap('Xc', function()
          require('substitute.exchange').cancel()
        end)
      end,
    })

    use('wellle/targets.vim')
    use({
      'kana/vim-textobj-user',
      requires = {
        'kana/vim-operator-user',
        {
          'glts/vim-textobj-comment',
          config = function()
            vim.g.textobj_comment_no_default_key_mappings = 1
            as.xmap('ax', '<Plug>(textobj-comment-a)')
            as.omap('ax', '<Plug>(textobj-comment-a)')
            as.xmap('ix', '<Plug>(textobj-comment-i)')
            as.omap('ix', '<Plug>(textobj-comment-i)')
          end,
        },
      },
    })
    -- }}}
    --------------------------------------------------------------------------------
    -- Search Tools {{{1
    --------------------------------------------------------------------------------
    use({ 'phaazon/hop.nvim', keys = { { 'n', 's' }, 'f', 'F' }, config = conf('hop') })

    -- }}}
    --------------------------------------------------------------------------------
    -- Themes  {{{1
    --------------------------------------------------------------------------------
    use('EdenEast/nightfox.nvim')
    use({
      'NTBBloodbath/doom-one.nvim',
      config = function()
        require('doom-one').setup({
          pumblend = {
            enable = true,
            transparency_amount = 3,
          },
        })
      end,
    })
    -- }}}
    ---------------------------------------------------------------------------------
    -- Dev plugins  {{{1
    ---------------------------------------------------------------------------------
    use({ 'rafcamlet/nvim-luapad', cmd = 'Luapad' })
    -- }}}
    ---------------------------------------------------------------------------------
    -- Personal plugins {{{1
    -----------------------------------------------------------------------------//
    use_local({
      'akinsho/pubspec-assist.nvim',
      ft = { 'dart', 'yaml' },
      local_path = 'personal',
      rocks = {
        {
          'lyaml',
          server = 'http://rocks.moonscript.org',
          env = { YAML_DIR = '/opt/homebrew/Cellar/libyaml/0.2.5/' },
        },
      },
      config = function()
        require('pubspec-assist').setup()
      end,
    })

    use_local({
      'akinsho/toggleterm.nvim',
      local_path = 'personal',
      config = conf('toggleterm'),
    })

    use_local({
      'akinsho/bufferline.nvim',
      config = conf('bufferline'),
      local_path = 'personal',
      requires = 'nvim-web-devicons',
    })

    use_local({
      'akinsho/git-conflict.nvim',
      local_path = 'personal',
      config = function()
        require('git-conflict').setup({
          disable_diagnostics = true,
        })
      end,
    })
    --}}}
    ---------------------------------------------------------------------------------
  end,
  log = { level = 'info' },
  config = {
    max_jobs = 30,
    compile_path = PACKER_COMPILED_PATH,
    display = {
      prompt_border = as.style.current.border,
      open_cmd = 'silent topleft 65vnew',
    },
    git = {
      clone_timeout = 240,
    },
    profile = {
      enable = true,
      threshold = 1,
    },
  },
})

as.command('PackerCompiledEdit', function()
  vim.cmd(fmt('edit %s', PACKER_COMPILED_PATH))
end)

as.command('PackerCompiledDelete', function()
  vim.fn.delete(PACKER_COMPILED_PATH)
  packer_notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
end)

if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(PACKER_COMPILED_PATH) then
  as.source(PACKER_COMPILED_PATH)
  vim.g.packer_compiled_loaded = true
end

as.nnoremap('<leader>ps', '<Cmd>PackerSync<CR>', 'packer: sync')

as.augroup('PackerSetupInit', {
  {
    event = 'BufWritePost',
    pattern = { '*/as/plugins/*.lua' },
    desc = 'Packer setup and reload',
    command = function()
      as.invalidate('as.plugins', true)
      packer.compile()
    end,
  },
})

-- vim:foldmethod=marker
