local api, fn = vim.api, vim.fn
local strwidth = api.nvim_strwidth
local highlight, ui, falsy, augroup = as.highlight, as.ui, as.falsy, as.augroup
local icons, border = ui.icons.lsp, ui.current.border
local codewindow = as.reqcall('codewindow')

return {
  {
    'gorbit99/codewindow.nvim',
    dev = true,
    event = { 'BufReadPre', 'BufNewFile' },
    init = function() highlight.plugin('codewindow', { { CodewindowBorder = { link = 'Dim' } } }) end,
    keys = {
      { '<localleader>mo', codewindow.open_minimap, desc = 'minimap: open' },
      { '<localleader>mc', codewindow.close_minimap, desc = 'minimap: close' },
      { '<localleader>mt', codewindow.toggle_minimap, desc = 'minimap: toggle window' },
      { '<localleader>mf', codewindow.toggle_focus, desc = 'minimap: toggle focus' },
    },
    opts = {
      auto_enable = false,
      auto_disable = { 'help', 'pgsql' },
      show_cursor = false,
      relative = 'editor',
      z_index = 1000,
      minimap_width = 12,
      max_minimap_height = math.floor(vim.o.lines * 0.8),
      -- stylua: ignore
      exclude_filetypes = {
        'lazy', 'neo-tree', 'undotree', 'alpha', 'gitcommit', 'gitrebase', 'Glance', 'help', 'mason',
        'noice', 'neo-tree-popup'
      },
    },
  },
  {
    'lukas-reineke/virt-column.nvim',
    event = 'VimEnter',
    opts = { char = '▕' },
    init = function()
      augroup('VirtCol', {
        event = { 'VimEnter', 'BufEnter', 'WinEnter' },
        command = function(args)
          ui.decorations.set_colorcolumn(
            args.buf,
            function(virtcolumn) require('virt-column').setup_buffer({ virtcolumn = virtcolumn }) end
          )
        end,
      })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'UIEnter',
    opts = {
      char = '│', -- ┆ ┊ 
      show_foldtext = false,
      context_char = '▎',
      char_priority = 12,
      show_current_context = true,
      show_current_context_start = true,
      show_current_context_start_on_current_line = false,
      show_first_indent_level = true,
      -- stylua: ignore
      filetype_exclude = {
        'dbout', 'neo-tree-popup', 'log', 'gitcommit',
        'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline',
        'undotree', 'markdown', 'norg', 'org', 'orgagenda',
        '', -- for all buffers without a file type
      },
    },
  },
  {
    'stevearc/dressing.nvim',
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
      end
    end,
    opts = {
      input = { enabled = false },
      select = {
        backend = { 'fzf_lua', 'builtin' },
        builtin = {
          border = border,
          min_height = 10,
          win_options = { winblend = 10 },
          mappings = { n = { ['q'] = 'Close' } },
        },
        nui = {
          min_height = 10,
          win_options = { winblend = 10 },
        },
      },
    },
  },
  {
    'rcarriga/nvim-notify',
    config = function()
      highlight.plugin('notify', {
        { NotifyERRORBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyWARNBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyINFOBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyDEBUGBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyTRACEBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyERRORBody = { link = 'NormalFloat' } },
        { NotifyWARNBody = { link = 'NormalFloat' } },
        { NotifyINFOBody = { link = 'NormalFloat' } },
        { NotifyDEBUGBody = { link = 'NormalFloat' } },
        { NotifyTRACEBody = { link = 'NormalFloat' } },
      })

      local notify = require('notify')

      notify.setup({
        timeout = 5000,
        stages = 'fade_in_slide_out',
        top_down = false,
        background_colour = 'NormalFloat',
        max_width = function() return math.floor(vim.o.columns * 0.6) end,
        max_height = function() return math.floor(vim.o.lines * 0.8) end,
        on_open = function(win)
          if not api.nvim_win_is_valid(win) then return end
          api.nvim_win_set_config(win, { border = border })
        end,
      })
      map('n', '<leader>nd', function() notify.dismiss({ silent = true, pending = true }) end, {
        desc = 'dismiss notifications',
      })
    end,
  },
  {
    'levouh/tint.nvim',
    event = 'WinNew',
    enabled = false,
    opts = {
      tint = -30,
      -- stylua: ignore
      highlight_ignore_patterns = {
        'WinSeparator', 'St.*', 'Comment', 'Panel.*', 'Telescope.*',
        'Bqf.*', 'VirtColumn', 'Headline.*', 'NeoTree.*',
      },
      window_ignore_function = function(win_id)
        local win, buf = vim.wo[win_id], vim.bo[vim.api.nvim_win_get_buf(win_id)]
        -- TODO: ideally tint should just ignore all buffers with a special type other than maybe "acwrite"
        -- since if there is a custom buftype it's probably a special buffer we always want to pay
        -- attention to whilst its open.
        -- BUG: neo-tree cannot be ignore as either nofile or by filetype as this causes tinting bugs
        if win.diff or not falsy(fn.win_gettype(win_id)) then return true end
        local ignore_bt = as.p_table({ terminal = true, prompt = true, nofile = false })
        local ignore_ft = as.p_table({
          ['Telescope.*'] = true,
          ['Neogit.*'] = true,
          ['flutterTools.*'] = true,
          ['qf'] = true,
        })
        return ignore_bt[buf.buftype] or ignore_ft[buf.filetype]
      end,
    },
  },
  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    dependencies = { 'kevinhwang91/promise-async' },
    keys = {
      { 'zR', function() require('ufo').openAllFolds() end, 'open all folds' },
      { 'zM', function() require('ufo').closeAllFolds() end, 'close all folds' },
      { 'zP', function() require('ufo').peekFoldedLinesUnderCursor() end, 'preview fold' },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        preview = { win_config = { winhighlight = 'Normal:Normal,FloatBorder:Normal' } },
        enable_get_fold_virt_text = true,
        close_fold_kinds = { 'imports', 'comment' },
        provider_selector = function(_, ft) return ft_map[ft] or { 'treesitter', 'indent' } end,
        fold_virt_text_handler = function(virt_text, _, end_lnum, width, truncate, ctx)
          local result, cur_width, padding = {}, 0, ''
          local suffix_width = strwidth(ctx.text)
          local target_width = width - suffix_width

          for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = strwidth(chunk_text)
            if target_width > cur_width + chunk_width then
              table.insert(result, chunk)
            else
              chunk_text = truncate(chunk_text, target_width - cur_width)
              local hl_group = chunk[2]
              table.insert(result, { chunk_text, hl_group })
              chunk_width = strwidth(chunk_text)
              if cur_width + chunk_width < target_width then
                padding = padding .. (' '):rep(target_width - cur_width - chunk_width)
              end
              break
            end
            cur_width = cur_width + chunk_width
          end

          if ft_map[vim.bo[ctx.bufnr].ft] == 'lsp' then
            table.insert(result, { ' ⋯ ', 'UfoFoldedEllipsis' })
            return result
          end

          local end_text = ctx.get_fold_virt_text(end_lnum)
          -- reformat the end text to trim excess whitespace from
          -- indentation usually the first item is indentation
          if end_text[1] and end_text[1][1] then end_text[1][1] = end_text[1][1]:gsub('[%s\t]+', '') end

          vim.list_extend(result, { { ' ⋯ ', 'UfoFoldedEllipsis' }, unpack(end_text) })
          table.insert(result, { padding, '' })
          return result
        end,
      })
    end,
  },
  {
    'akinsho/bufferline.nvim',
    dev = true,
    event = 'UIEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local bufferline = require('bufferline')
      bufferline.setup({
        options = {
          debug = { logging = true },
          style_preset = { bufferline.style_preset.minimal },
          mode = 'buffers',
          sort_by = 'insert_after_current',
          right_mouse_command = 'vert sbuffer %d',
          show_close_icon = false,
          show_buffer_close_icons = true,
          indicator = { style = 'underline' },
          diagnostics = 'nvim_lsp',
          diagnostics_indicator = function(count, level)
            level = level:match('warn') and 'warn' or level
            return (icons[level] or '?') .. ' ' .. count
          end,
          diagnostics_update_in_insert = false,
          hover = { enabled = true, reveal = { 'close' } },
          offsets = {
            {
              text = 'EXPLORER',
              filetype = 'neo-tree',
              highlight = 'PanelHeading',
              text_align = 'left',
              separator = true,
            },
            {
              text = ' FLUTTER OUTLINE',
              filetype = 'flutterToolsOutline',
              highlight = 'PanelHeading',
              separator = true,
            },
            {
              text = 'UNDOTREE',
              filetype = 'undotree',
              highlight = 'PanelHeading',
              separator = true,
            },
            {
              text = ' DATABASE VIEWER',
              filetype = 'dbui',
              highlight = 'PanelHeading',
              separator = true,
            },
            {
              text = ' DIFF VIEW',
              filetype = 'DiffviewFiles',
              highlight = 'PanelHeading',
              separator = true,
            },
          },
          groups = {
            options = { toggle_hidden_on_enter = true },
            items = {
              bufferline.groups.builtin.pinned:with({ icon = '' }),
              bufferline.groups.builtin.ungrouped,
              {
                name = 'Dependencies',
                icon = '',
                highlight = { fg = '#ECBE7B' },
                matcher = function(buf) return vim.startswith(buf.path, vim.env.VIMRUNTIME) end,
              },
              {
                name = 'Terraform',
                matcher = function(buf) return buf.name:match('%.tf') ~= nil end,
              },
              {
                name = 'Kubernetes',
                matcher = function(buf) return buf.name:match('kubernetes') and buf.name:match('%.yaml') end,
              },
              {
                name = 'SQL',
                matcher = function(buf) return buf.name:match('%.sql$') end,
              },
              {
                name = 'tests',
                icon = '',
                matcher = function(buf)
                  local name = buf.name
                  return name:match('[_%.]spec') or name:match('[_%.]test')
                end,
              },
              {
                name = 'docs',
                icon = '',
                matcher = function(buf)
                  if vim.bo[buf.id].filetype == 'man' or buf.path:match('man://') then return true end
                  for _, ext in ipairs({ 'md', 'txt', 'org', 'norg', 'wiki' }) do
                    if ext == fn.fnamemodify(buf.path, ':e') then return true end
                  end
                end,
              },
            },
          },
        },
      })

      map('n', '[b', '<Cmd>BufferLineMoveNext<CR>', { desc = 'bufferline: move next' })
      map('n', ']b', '<Cmd>BufferLineMovePrev<CR>', { desc = 'bufferline: move prev' })
      map('n', 'gbb', '<Cmd>BufferLinePick<CR>', { desc = 'bufferline: pick buffer' })
      map('n', 'gbd', '<Cmd>BufferLinePickClose<CR>', { desc = 'bufferline: delete buffer' })
      map('n', '<S-tab>', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'bufferline: prev' })
      map('n', '<leader><tab>', '<Cmd>BufferLineCycleNext<CR>', { desc = 'bufferline: next' })
    end,
  },
}
