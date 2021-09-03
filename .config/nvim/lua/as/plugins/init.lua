local utils = require 'as.plugins.utils'

local conf = utils.conf
local use_local = utils.use_local
local packer_notify = utils.packer_notify

local fn = vim.fn
local has = as.has
local is_work = has 'mac'
local fmt = string.format

local PACKER_COMPILED_PATH = fn.stdpath 'cache' .. '/packer/packer_compiled.lua'

-----------------------------------------------------------------------------//
-- Bootstrap Packer {{{3
-----------------------------------------------------------------------------//
utils.bootstrap_packer()
----------------------------------------------------------------------------- }}}1
-- cfilter plugin allows filter down an existing quickfix list
vim.cmd 'packadd! cfilter'

-- FIXME: currently because mpack is required BEFORE packer
-- loads it can't be loaded by packer which doesn't set the
-- packpath till later in the setup process e.g. when packer compiled is loaded
-- so the following command needs to be manually executed
-- luarocks install --lua-version=5.1 mpack
local ok, impatient = as.safe_require 'impatient'
if ok then
  impatient.enable_profile()
end

--- NOTE "use" functions cannot call *upvalues* i.e. the functions
--- passed to setup or config etc. cannot reference aliased functions
--- or local variables
require('packer').startup {
  function(use, use_rocks)
    use_local { 'wbthomason/packer.nvim', local_path = 'contributing', opt = true }
    -----------------------------------------------------------------------------//
    -- Core {{{3
    -----------------------------------------------------------------------------//
    use_rocks 'penlight'

    -- TODO: this plugin will be redundant once https://github.com/neovim/neovim/pull/15436 is merged
    use 'lewis6991/impatient.nvim'

    use {
      'ahmedkhalf/project.nvim',
      config = function()
        require('project_nvim').setup()
      end,
    }

    use {
      'nvim-telescope/telescope.nvim',
      event = 'CursorHold',
      cmd = 'Telescope',
      keys = { '<c-p>', '<leader>fo', '<leader>ff', '<leader>fs' },
      module_pattern = 'telescope.*',
      config = conf 'telescope',
      requires = {
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        {
          'nvim-telescope/telescope-frecency.nvim',
          requires = 'tami5/sqlite.lua',
          after = 'telescope.nvim',
        },
        { 'camgraff/telescope-tmux.nvim' },
        { 'nvim-telescope/telescope-smart-history.nvim' },
      },
    }

    use 'kyazdani42/nvim-web-devicons'

    use { 'folke/which-key.nvim', config = conf 'whichkey' }

    use {
      'folke/trouble.nvim',
      keys = { '<leader>ld' },
      cmd = { 'TroubleToggle' },
      setup = function()
        require('which-key').register {
          ['<leader>l'] = {
            d = 'trouble: toggle',
            r = 'trouble: lsp references',
          },
          ['[d'] = 'trouble: next item',
          [']d'] = 'trouble: previous item',
        }
      end,
      requires = 'nvim-web-devicons',
      config = function()
        local H = require 'as.highlights'
        H.plugin(
          'trouble',
          { 'TroubleNormal', { link = 'PanelBackground' } },
          { 'TroubleText', { link = 'PanelBackground' } },
          { 'TroubleIndent', { link = 'PanelVertSplit' } },
          { 'TroubleFoldIcon', { guifg = 'yellow', gui = 'bold' } },
          { 'TroubleLocation', { guifg = H.get_hl('Comment', 'fg') } }
        )
        local trouble = require 'trouble'
        as.nnoremap('<leader>ld', '<cmd>TroubleToggle lsp_workspace_diagnostics<CR>')
        as.nnoremap('<leader>lr', '<cmd>TroubleToggle lsp_references<CR>')
        as.nnoremap(']d', function()
          trouble.previous { skip_groups = true, jump = true }
        end)
        as.nnoremap('[d', function()
          trouble.next { skip_groups = true, jump = true }
        end)
        trouble.setup { auto_close = true, auto_preview = false }
      end,
    }

    use {
      'rmagatti/auto-session',
      config = function()
        require('auto-session').setup {
          auto_session_root_dir = ('%s/session/auto/'):format(vim.fn.stdpath 'data'),
        }
      end,
    }

    use {
      'christoomey/vim-tmux-navigator',
      config = function()
        vim.g.tmux_navigator_no_mappings = 1
        as.nnoremap('<C-H>', '<cmd>TmuxNavigateLeft<cr>')
        as.nnoremap('<C-J>', '<cmd>TmuxNavigateDown<cr>')
        as.nnoremap('<C-K>', '<cmd>TmuxNavigateUp<cr>')
        as.nnoremap('<C-L>', '<cmd>TmuxNavigateRight<cr>')
        -- Disable tmux navigator when zooming the Vim pane
        vim.g.tmux_navigator_disable_when_zoomed = 1
        vim.g.tmux_navigator_save_on_switch = 2
      end,
    }

    use {
      'nvim-lua/plenary.nvim',
      config = function()
        as.augroup('PlenaryTests', {
          {
            events = { 'BufEnter' },
            targets = { '*/personal/*/tests/*_spec.lua' },
            command = function()
              require('which-key').register({
                t = {
                  name = '+plenary',
                  f = { '<Plug>PlenaryTestFile', 'test file' },
                  d = {
                    "<cmd>PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}<CR>",
                    'test directory',
                  },
                },
              }, {
                prefix = '<localleader>',
                buffer = 0,
              })
            end,
          },
        })
      end,
    }

    use {
      'lukas-reineke/indent-blankline.nvim',
      config = function()
        require('indent_blankline').setup {
          char = '│', -- ┆ ┊ 
          show_foldtext = false,
          show_first_indent_level = true,
          filetype_exclude = {
            'startify',
            'dashboard',
            'log',
            'fugitive',
            'gitcommit',
            'packer',
            'vimwiki',
            'markdown',
            'json',
            'txt',
            'vista',
            'help',
            'NvimTree',
            'git',
            'TelescopePrompt',
            'undotree',
            'flutterToolsOutline',
            'org',
            'orgagenda',
            '', -- for all buffers without a file type
          },
          buftype_exclude = { 'terminal', 'nofile' },
          show_current_context = true,
          context_patterns = {
            'class',
            'function',
            'method',
            'block',
            'list_literal',
            'selector',
            '^if',
            '^table',
            'if_statement',
            'while',
            'for',
          },
        }
      end,
    }

    use { 'kyazdani42/nvim-tree.lua', config = conf 'nvim-tree', requires = 'nvim-web-devicons' }
    -- }}}
    -----------------------------------------------------------------------------//
    -- LSP,Completion & Debugger {{{1
    -----------------------------------------------------------------------------//
    use {
      'kabouzeid/nvim-lspinstall',
      module = 'lspinstall',
      requires = 'nvim-lspconfig',
      config = function()
        require('lspinstall').post_install_hook = function()
          as.lsp.setup_servers()
          vim.cmd 'bufdo e'
        end
      end,
    }

    use { 'neovim/nvim-lspconfig', event = 'BufReadPre', config = conf 'lspconfig' }

    use {
      'kosayoda/nvim-lightbulb',
      config = function()
        as.augroup('NvimLightbulb', {
          {
            events = { 'CursorHold', 'CursorHoldI' },
            targets = { '*' },
            command = function()
              require('nvim-lightbulb').update_lightbulb {
                sign = { enabled = false },
                virtual_text = { enabled = true },
              }
            end,
          },
        })
      end,
    }

    use {
      'jose-elias-alvarez/null-ls.nvim',
      requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
      -- trigger loading after lspconfig has started the other servers
      -- since there is otherwise a race condition and null-ls' setup would
      -- have to be moved into lspconfig.lua otherwise
      event = 'User LspServersStarted',
      config = function()
        local null_ls = require 'null-ls'
        null_ls.config {
          debounce = 150,
          sources = {
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.prettier.with {
              filetypes = { 'html', 'json', 'yaml', 'graphql', 'markdown' },
            },
          },
        }
        require('lspconfig')['null-ls'].setup {
          on_attach = as.lsp.on_attach,
        }
      end,
    }

    use_local {
      'windwp/lsp-fastaction.nvim',
      local_path = 'contributing',
      config = function()
        local fastaction = require 'lsp-fastaction'
        fastaction.setup {
          action_data = {
            dart = {
              { pattern = 'import library', key = 'i', order = 1 },
              { pattern = 'wrap with widget', key = 'w', order = 2 },
              { pattern = 'column', key = 'c', order = 3 },
              { pattern = 'row', key = 'r', order = 3 },
              { pattern = 'container', key = 'C', order = 4 },
              { pattern = 'center', key = 'E', order = 4 },
              { pattern = 'padding', key = 'p', order = 4 },
              { pattern = 'remove', key = 'r', order = 5 },
              -- range code action
              { pattern = "surround with %'if'", key = 'i', order = 2 },
              { pattern = 'try%-catch', key = 't', order = 2 },
              { pattern = 'for%-in', key = 'f', order = 2 },
              { pattern = 'setstate', key = 's', order = 2 },
            },
          },
        }
        as.xnoremap('<leader>ca', "<esc><Cmd>lua require('lsp-fastaction').range_code_action()<CR>")
        require('which-key').register {
          ['<leader>ca'] = { fastaction.code_action, 'lsp: code action' },
        }
      end,
    }

    use {
      'ray-x/lsp_signature.nvim',
      branch = 'fix_pos_fun',
      config = function()
        require('lsp_signature').setup {
          bind = true,
          fix_pos = function(signatures, _) -- second argument is the client
            return signatures[1].activeParameter >= 0 and signatures[1].parameters > 1
          end,
          hint_enable = false,
          handler_opts = {
            border = 'rounded',
          },
        }
      end,
    }

    use_local {
      'akinsho/flutter-tools.nvim',
      requires = { 'nvim-dap', 'plenary.nvim' },
      local_path = 'personal',
      config = function()
        --- TODO: this causes lsp-status to be loaded early, increasing it's startup time
        local status_ok, lsp_status = as.safe_require('lsp-status', { silent = true })
        local capabilities = status_ok and lsp_status.capabilities or nil
        require('flutter-tools').setup {
          ui = {
            border = 'rounded',
          },
          debugger = {
            enabled = true,
          },
          outline = {
            -- only auto open if there is space
            auto_open = vim.o.columns > 220,
          },
          decorations = {
            statusline = {
              device = true,
              app_version = true,
            },
          },
          widget_guides = {
            enabled = true,
            debug = true,
          },
          dev_log = { open_cmd = 'tabedit' },
          lsp = {
            settings = {
              showTodos = false,
            },
            on_attach = as.lsp and as.lsp.on_attach or nil,
            --- This is necessary to prevent lsp-status' capabilities being
            --- given priority over that of the default config
            capabilities = function(defaults)
              return vim.tbl_deep_extend('keep', defaults, capabilities)
            end,
          },
        }
      end,
    }

    use {
      'hrsh7th/nvim-cmp',
      module = 'cmp',
      event = 'InsertEnter',
      requires = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'f3fora/cmp-spell', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
      },
      config = conf 'cmp',
    }

    use {
      'AckslD/nvim-neoclip.lua',
      config = function()
        require('neoclip').setup {
          keys = {
            i = {
              select = '<c-p>',
              paste = '<CR>',
              paste_behind = '<c-k>',
            },
            n = {
              select = 'p',
              paste = '<CR>',
              paste_behind = 'P',
            },
          },
        }
        local function clip()
          require('telescope').extensions.neoclip.default(
            require('telescope.themes').get_dropdown()
          )
        end
        require('which-key').register {
          ['<localleader>p'] = { clip, 'neoclip: open yank history' },
        }
      end,
    }

    use {
      'L3MON4D3/LuaSnip',
      event = 'InsertEnter',
      module = 'luasnip',
      requires = 'rafamadriz/friendly-snippets',
      config = conf 'luasnip',
    }
    -- }}}
    -----------------------------------------------------------------------------//
    -- Testing and Debugging {{{1
    -----------------------------------------------------------------------------//
    use {
      'vim-test/vim-test',
      cmd = { 'Test*' },
      keys = { '<localleader>tf', '<localleader>tn', '<localleader>ts' },
      setup = function()
        require('which-key').register({
          t = {
            name = '+vim-test',
            f = 'test: file',
            n = 'test: nearest',
            s = 'test: suite',
          },
        }, {
          prefix = '<localleader>',
        })
      end,
      config = function()
        vim.cmd [[
          function! ToggleTermStrategy(cmd) abort
            call luaeval("require('toggleterm').exec(_A[1])", [a:cmd])
          endfunction

          let g:test#custom_strategies = {'toggleterm': function('ToggleTermStrategy')}
        ]]
        vim.g['test#strategy'] = 'toggleterm'
        as.nnoremap('<localleader>tf', '<cmd>TestFile<CR>')
        as.nnoremap('<localleader>tn', '<cmd>TestNearest<CR>')
        as.nnoremap('<localleader>ts', '<cmd>TestSuite<CR>')
      end,
    }
    use {
      'mfussenegger/nvim-dap',
      module = 'dap',
      keys = { '<localleader>dc' },
      setup = conf('dap').setup,
      config = conf('dap').config,
      requires = {
        {
          'rcarriga/nvim-dap-ui',
          requires = 'nvim-dap',
          after = 'nvim-dap',
          config = function()
            require('dapui').setup()
          end,
        },
      },
    }

    use 'folke/lua-dev.nvim'

    --}}}
    -----------------------------------------------------------------------------//
    -- UI
    -----------------------------------------------------------------------------//

    use {
      'nvim-lua/lsp-status.nvim',
      config = function()
        local status = require 'lsp-status'
        status.config {
          indicator_hint = '',
          indicator_info = '',
          indicator_errors = '✗',
          indicator_warnings = '',
          status_symbol = ' ',
        }
        status.register_progress()
      end,
    }
    --------------------------------------------------------------------------------
    -- Utilities {{{1
    --------------------------------------------------------------------------------
    use 'nanotee/luv-vimdocs'
    use 'milisims/nvim-luaref'
    use {
      'kevinhwang91/nvim-bqf',
      config = function()
        require('as.highlights').plugin('bqf', { 'BqfPreviewBorder', { guifg = 'Gray' } })
      end,
    }

    -- prevent select and visual mode from overwriting the clipboard
    use {
      'kevinhwang91/nvim-hclipboard',
      event = 'InsertCharPre',
      config = function()
        require('hclipboard').start()
      end,
    }

    use {
      'arecarn/vim-fold-cycle',
      config = function()
        vim.g.fold_cycle_default_mapping = 0
        as.nmap('<BS>', '<Plug>(fold-cycle-close)')
      end,
    }
    use {
      'windwp/nvim-autopairs',
      after = 'nvim-cmp',
      config = function()
        require('nvim-autopairs').setup {
          close_triple_quotes = true,
          check_ts = false,
        }
      end,
    }
    use {
      'karb94/neoscroll.nvim',
      config = function()
        require('neoscroll').setup {
          mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', 'zt', 'zz', 'zb' },
          stop_eof = false,
          hide_cursor = false,
        }
      end,
    }
    use {
      'mg979/vim-visual-multi',
      config = function()
        vim.g.VM_highlight_matches = 'underline'
        vim.g.VM_theme = 'codedark'
        vim.g.VM_maps = {
          ['Find Under'] = '<C-e>',
          ['Find Subword Under'] = '<C-e>',
          ['Select Cursor Down'] = [[\j]],
          ['Select Cursor Up'] = [[\k]],
        }
      end,
    }
    use {
      'itchyny/vim-highlighturl',
      config = function()
        vim.g.highlighturl_guifg = require('as.highlights').get_hl('Keyword', 'fg')
      end,
    }

    use {
      'rcarriga/nvim-notify',
      config = function()
        local notify = require 'notify'
        notify.setup {
          stages = 'fade_in_slide_out', -- fade
          timeout = 3000,
        }
        ---Send a notification
        --@param msg of the notification to show to the user
        --@param level Optional log level
        --@param opts Dictionary with optional options (timeout, etc)
        vim.notify = function(msg, level, opts)
          local l = vim.log.levels
          opts = opts or {}
          level = level or l.INFO
          local levels = {
            [l.DEBUG] = 'Debug',
            [l.INFO] = 'Information',
            [l.WARN] = 'Warning',
            [l.ERROR] = 'Error',
          }
          opts.title = opts.title or type(level) == 'string' and level or levels[level]
          notify(msg, level, opts)
        end
        local hls = { DEBUG = 'Normal', INFO = 'Directory', WARN = 'WarningMsg', ERROR = 'Error' }
        as.command {
          'NotificationHistory',
          function()
            local history = notify.history()
            local messages = vim.tbl_map(function(notif)
              return { unpack(notif.message), hls[notif.level] }
            end, history)
            for _, message in ipairs(messages) do
              vim.api.nvim_echo({ message }, true, {})
            end
          end,
        }
      end,
    }

    use {
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      keys = '<leader>u',
      setup = function()
        require('which-key').register {
          ['<leader>u'] = 'undotree: toggle',
        }
      end,
      config = function()
        vim.g.undotree_TreeNodeShape = '◉' -- Alternative: '◦'
        vim.g.undotree_SetFocusWhenToggle = 1
        as.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>')
      end,
    }
    use {
      'iamcco/markdown-preview.nvim',
      run = function()
        vim.fn['mkdp#util#install']()
      end,
      ft = { 'markdown' },
      config = function()
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
      end,
    }
    use {
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup({ '*' }, {
          RGB = false,
          mode = 'background',
        })
      end,
    }
    --------------------------------------------------------------------------------
    -- Knowledge and task management {{{1
    --------------------------------------------------------------------------------
    use {
      'soywod/himalaya', --- Email in nvim
      rtp = 'vim',
      run = 'curl -sSL https://raw.githubusercontent.com/soywod/himalaya/master/install.sh | PREFIX=~/.local sh',
      config = function()
        require('which-key').register({
          e = {
            name = '+email',
            l = { '<Cmd>Himalaya<CR>', 'list' },
          },
        }, {
          prefix = '<localleader>',
        })
      end,
    }

    use {
      'vimwiki/vimwiki',
      branch = 'dev',
      keys = { '<leader>ww', '<leader>wt', '<leader>wi' },
      event = { 'BufEnter *.wiki' },
      setup = conf('vimwiki').setup,
      config = conf('vimwiki').config,
    }

    use {
      'vhyrro/neorg',
      branch = 'unstable',
      requires = { 'vhyrro/neorg-telescope' },
      config = function()
        require('neorg').setup {
          load = {
            ['core.defaults'] = {},
            ['core.integrations.telescope'] = {},
            ['core.keybinds'] = {
              config = {
                default_keybinds = true,
                neorg_leader = '<Leader>o',
              },
            },
            ['core.norg.completion'] = {
              config = {
                engine = 'nvim-cmp',
              },
            },
            ['core.norg.concealer'] = {},
            ['core.norg.dirman'] = {
              config = {
                workspaces = {
                  notes = '~/Dropbox/neorg',
                },
              },
            },
          },
        }
      end,
    }

    use { 'kristijanhusak/orgmode.nvim', config = conf 'orgmode' }

    use_local {
      'akinsho/org-bullets.nvim',
      requires = 'orgmode.nvim',
      local_path = 'personal',
      config = function()
        require('org-bullets').setup()
      end,
    }
    -- }}}
    --------------------------------------------------------------------------------
    -- Profiling {{{1
    --------------------------------------------------------------------------------
    use {
      'dstein64/vim-startuptime',
      cmd = 'StartupTime',
      config = function()
        vim.g.startuptime_tries = 10
        vim.g.startuptime_exe_args = { '+let g:auto_session_enabled = 0' }
      end,
    }
    -- }}}
    --------------------------------------------------------------------------------
    -- TPOPE {{{1
    --------------------------------------------------------------------------------
    use 'tpope/vim-eunuch'
    use 'tpope/vim-sleuth'
    use 'tpope/vim-repeat'
    use {
      'tpope/vim-abolish',
      config = function()
        local opts = { silent = false }
        as.nnoremap('<localleader>[', ':S/<C-R><C-W>//<LEFT>', opts)
        as.nnoremap('<localleader>]', ':%S/<C-r><C-w>//c<left><left>', opts)
        as.xnoremap('<localleader>[', [["zy:%S/<C-r><C-o>"//c<left><left>]], opts)
      end,
    }
    -- sets searchable path for filetypes like go so 'gf' works
    use { 'tpope/vim-apathy', ft = { 'go', 'python', 'javascript', 'typescript' } }
    use { 'tpope/vim-projectionist', config = conf 'vim-projectionist' }
    use {
      'tpope/vim-surround',
      config = function()
        as.xmap('s', '<Plug>VSurround')
        as.xmap('s', '<Plug>VSurround')
      end,
    }
    -- }}}
    --------------------------------------------------------------------------------
    -- Syntax {{{1
    --------------------------------------------------------------------------------
    -- TODO: converting a plugin from disabled to enabled inside a require doesn't work
    use_local {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf 'treesitter',
      local_path = 'contributing',
      requires = { 'nvim-treesitter/nvim-treesitter-textobjects', 'p00f/nvim-ts-rainbow' },
    }
    use {
      'nvim-treesitter/playground',
      keys = '<leader>E',
      cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
      setup = function()
        require('which-key').register {
          ['<leader>E'] = 'treesitter: highlight cursor group',
        }
      end,
      config = function()
        as.nnoremap('<leader>E', '<Cmd>TSHighlightCapturesUnderCursor<CR>')
      end,
    }

    -- Use <Tab> to escape from pairs such as ""|''|() etc.
    use {
      'abecodes/tabout.nvim',
      wants = { 'nvim-treesitter' },
      after = { 'nvim-cmp' },
      config = function()
        require('tabout').setup {
          ignore_beginning = false,
        }
      end,
    }

    use {
      'mfussenegger/nvim-ts-hint-textobject',
      config = function()
        as.omap('m', ":<C-U>lua require('tsht').nodes()<CR>")
        as.xnoremap('m', ":'<'>lua require('tsht').nodes()<CR>")
      end,
    }

    use {
      'lewis6991/spellsitter.nvim',
      config = function()
        require('spellsitter').setup {}
      end,
    }
    use 'dart-lang/dart-vim-plugin'
    use 'plasticboy/vim-markdown'
    use 'mtdl9/vim-log-highlighting'
    ---}}}
    --------------------------------------------------------------------------------
    -- Git {{{1
    --------------------------------------------------------------------------------
    use {
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
        local linker = require 'gitlinker'
        linker.setup { mappings = '<localleader>gu' }
        as.nnoremap('<localleader>go', function()
          linker.get_repo_url { action_callback = require('gitlinker.actions').open_in_browser }
        end)
      end,
    }
    use { 'lewis6991/gitsigns.nvim', config = conf 'gitsigns' }
    use {
      'rhysd/conflict-marker.vim',
      config = function()
        require('as.highlights').plugin(
          'conflictMarker',
          { 'ConflictMarkerBegin', { guibg = '#2f7366' } },
          { 'ConflictMarkerOurs', { guibg = '#2e5049' } },
          { 'ConflictMarkerTheirs', { guibg = '#344f69' } },
          { 'ConflictMarkerEnd', { guibg = '#2f628e' } },
          { 'ConflictMarkerCommonAncestorsHunk', { guibg = '#754a81' } }
        )
        -- disable the default highlight group
        vim.g.conflict_marker_highlight_group = ''
        -- Include text after begin and end markers
        vim.g.conflict_marker_begin = '^<<<<<<< .*$'
        vim.g.conflict_marker_end = '^>>>>>>> .*$'
      end,
    }
    use {
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      keys = { '<localleader>gs', '<localleader>gl', '<localleader>gp' },
      requires = 'plenary.nvim',
      setup = conf('neogit').setup,
      config = conf('neogit').config,
    }
    use {
      'sindrets/diffview.nvim',
      cmd = { 'DiffviewOpen', 'DiffViewFileHistory' },
      module = 'diffview',
      keys = '<localleader>gd',
      setup = function()
        require('which-key').register { ['<localleader>gd'] = 'diffview: diff HEAD' }
      end,
      config = function()
        as.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>')
        require('diffview').setup {
          key_bindings = {
            file_panel = { q = '<Cmd>DiffviewClose<CR>' },
            view = { q = '<Cmd>DiffviewClose<CR>' },
          },
        }
      end,
    }

    use {
      'pwntester/octo.nvim',
      cmd = 'Octo*',
      setup = function()
        require('which-key').register {
          ['<localleader>o'] = {
            name = '+octo',
            p = { name = '+pull-request', l = { '<cmd>Octo pr list<CR>', 'list' } },
            i = { name = '+issues', l = { '<cmd>Octo issue list<CR>', 'list' } },
          },
        }
      end,
      config = function()
        require('octo').setup()
      end,
    }
    ---}}}
    --------------------------------------------------------------------------------
    -- Text Objects {{{1
    --------------------------------------------------------------------------------
    use {
      'AndrewRadev/splitjoin.vim',
      config = function()
        require('which-key').register {
          gS = 'splitjoin: split',
          gJ = 'splitjoin: join',
        }
      end,
    }
    use {
      'AndrewRadev/dsf.vim',
      config = function()
        vim.g.dsf_no_mappings = 1
        require('which-key').register {
          d = {
            name = '+dsf: function text object',
            s = {
              f = { '<Plug>DsfDelete', 'delete surrounding function' },
              nf = { '<Plug>DsfNextDelete', 'delete next surrounding function' },
            },
          },
          c = {
            name = '+dsf: function text object',
            s = {
              f = { '<Plug>DsfChange', 'change surrounding function' },
              nf = { '<Plug>DsfNextChange', 'change next surrounding function' },
            },
          },
        }
      end,
    }
    use 'chaoren/vim-wordmotion'

    use {
      'b3nj5m1n/kommentary',
      config = function()
        require('kommentary.config').configure_language(
          'lua',
          { prefer_single_line_comments = true }
        )
      end,
    }
    use {
      'tommcdo/vim-exchange',
      config = function()
        require('as.highlights').plugin('exchange', { 'ExchangeRegion', { link = 'Search' } })
        vim.g.exchange_no_mappings = 1
        as.xmap('X', '<Plug>(Exchange)')
        as.nmap('X', '<Plug>(Exchange)')
        as.nmap('Xc', '<Plug>(ExchangeClear)')
      end,
    }
    use 'wellle/targets.vim'
    use {
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
    }
    -- }}}
    --------------------------------------------------------------------------------
    -- Search Tools {{{1
    --------------------------------------------------------------------------------
    use {
      'phaazon/hop.nvim',
      keys = { { 'n', 's' } },
      config = function()
        local hop = require 'hop'
        -- remove h,j,k,l from hops list of keys
        hop.setup { keys = 'etovxqpdygfbzcisuran' }
        as.nnoremap('s', hop.hint_char1)
      end,
    }
    -- lazy load as it is very expensive to load during startup i.e. 20ms+
    -- FIXME: UpdateRemotePlugins doesn't seem to be called for lazy loaded plugins
    --@see: https://github.com/wbthomason/packer.nvim/issues/464
    use {
      'gelguy/wilder.nvim',
      event = { 'CursorHold', 'CmdlineEnter' },
      rocks = { 'luarocks-fetch-gitrec', 'pcre2' },
      requires = { 'romgrk/fzy-lua-native' },
      config = function()
        as.source('vimscript/wilder.vim', true)
      end,
    }

    use {
      'folke/todo-comments.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = function()
        require('todo-comments').setup {
          highlight = {
            exclude = { 'org', 'orgagenda', 'vimwiki', 'markdown' },
          },
        }
        require('which-key').register {
          ['<leader>lt'] = { '<Cmd>TodoTrouble<CR>', 'trouble: todos' },
        }
      end,
    }
    -- }}}
    --------------------------------------------------------------------------------
    -- Themes  {{{1
    --------------------------------------------------------------------------------
    use 'NTBBloodbath/doom-one.nvim'
    use 'monsonjeremy/onedark.nvim'
    use 'marko-cerovac/material.nvim'
    use {
      'projekt0n/github-nvim-theme',
      event = 'ColorScheme github',
      config = function()
        require('github-theme').setup()
      end,
    }
    use { 'Th3Whit3Wolf/one-nvim', opt = true }
    -- }}}
    ---------------------------------------------------------------------------------
    -- Dev plugins  {{{1
    ---------------------------------------------------------------------------------
    use { 'rafcamlet/nvim-luapad', cmd = 'Luapad', disable = is_work }
    -- }}}
    ---------------------------------------------------------------------------------
    -- Personal plugins {{{1
    -----------------------------------------------------------------------------//
    use_local {
      'akinsho/dependency-assist.nvim',
      local_path = 'personal',
      config = function()
        require('dependency_assist').setup()
      end,
    }

    use_local {
      'akinsho/toggleterm.nvim',
      local_path = 'personal',
      config = function()
        require('toggleterm').setup {
          open_mapping = [[<c-\>]],
          shade_filetypes = { 'none' },
          direction = 'vertical',
          start_in_insert = true,
          float_opts = { border = 'curved', winblend = 3 },
          size = function(term)
            if term.direction == 'horizontal' then
              return 15
            elseif term.direction == 'vertical' then
              return math.floor(vim.o.columns * 0.4)
            end
          end,
        }

        local float_handler = function(term)
          if vim.fn.mapcheck('jk', 't') ~= '' then
            vim.api.nvim_buf_del_keymap(term.bufnr, 't', 'jk')
            vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
          end
        end

        local Terminal = require('toggleterm.terminal').Terminal

        local lazygit = Terminal:new {
          cmd = 'lazygit',
          dir = 'git_dir',
          hidden = true,
          direction = 'float',
          on_open = float_handler,
        }

        local htop = Terminal:new {
          cmd = 'htop',
          hidden = 'true',
          direction = 'float',
          on_open = float_handler,
        }

        as.command {
          'Htop',
          function()
            htop:toggle()
          end,
        }

        require('which-key').register {
          ['<leader>lg'] = {
            function()
              lazygit:toggle()
            end,
            'toggleterm: toggle lazygit',
          },
        }
      end,
    }
    use_local {
      'akinsho/bufferline.nvim',
      config = conf 'bufferline',
      local_path = 'personal',
      requires = 'nvim-web-devicons',
    }
    --}}}
    ---------------------------------------------------------------------------------
  end,
  log = { level = 'info' },
  config = {
    compile_path = PACKER_COMPILED_PATH,
    display = {
      prompt_border = 'rounded',
      open_cmd = 'silent topleft 65vnew',
    },
    profile = {
      enable = true,
      threshold = 1,
    },
  },
}

as.command {
  'PackerCompiledEdit',
  function()
    vim.cmd(fmt('edit %s', PACKER_COMPILED_PATH))
  end,
}

as.command {
  'PackerCompiledDelete',
  function()
    vim.fn.delete(PACKER_COMPILED_PATH)
    packer_notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
  end,
}

if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(PACKER_COMPILED_PATH) then
  as.source(PACKER_COMPILED_PATH)
  vim.g.packer_compiled_loaded = true
end

as.augroup('PackerSetupInit', {
  {
    events = { 'BufWritePost' },
    targets = { '*/as/plugins/*.lua' },
    command = function()
      as.invalidate('as.plugins', true)
      require('packer').compile()
      packer_notify 'packer compiled...'
    end,
  },
})
as.nnoremap('<leader>ps', [[<Cmd>PackerSync<CR>]])
as.nnoremap('<leader>pc', [[<Cmd>PackerClean<CR>]])

-- vim:foldmethod=marker
