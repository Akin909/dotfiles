return function()
  local function is_ft(b, ft)
    return vim.bo[b].filetype == ft
  end

  local symbols = { error = ' ', warning = ' ', info = ' ' }

  local function diagnostics_indicator(_, _, diagnostics)
    local result = {}
    for name, count in pairs(diagnostics) do
      if symbols[name] and count > 0 then
        table.insert(result, symbols[name] .. count)
      end
    end
    result = table.concat(result, ' ')
    return #result > 0 and result or ''
  end

  local function custom_filter(buf, buf_nums)
    local logs = vim.tbl_filter(function(b)
      return is_ft(b, 'log')
    end, buf_nums)
    if vim.tbl_isempty(logs) then
      return true
    end
    local tab_num = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr '$'
    local is_log = is_ft(buf, 'log')
    if last_tab == 1 then
      return true
    end
    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
  end

  ---@diagnostic disable-next-line: unused-function, unused-local
  local function sort_by_mtime(a, b)
    local astat = vim.loop.fs_stat(a.path)
    local bstat = vim.loop.fs_stat(b.path)
    local mod_a = astat and astat.mtime.sec or 0
    local mod_b = bstat and bstat.mtime.sec or 0
    return mod_a > mod_b
  end

  require('bufferline').setup {
    options = {
      sort_by = sort_by_mtime,
      right_mouse_command = 'vert sbuffer %d',
      show_close_icon = false,
      ---based on https://github.com/kovidgoyal/kitty/issues/957
      separator_style = os.getenv 'KITTY_WINDOW_ID' and 'slant' or 'padded_slant',
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = diagnostics_indicator,
      diagnostics_update_in_insert = false,
      custom_filter = custom_filter,
      offsets = {
        {
          filetype = 'undotree',
          text = 'Undotree',
          highlight = 'PanelHeading',
          padding = 1,
        },
        {
          filetype = 'NvimTree',
          text = 'Explorer',
          highlight = 'PanelHeading',
          padding = 1,
        },
        {
          filetype = 'DiffviewFiles',
          text = 'Diff View',
          highlight = 'PanelHeading',
          padding = 1,
        },
        {
          filetype = 'flutterToolsOutline',
          text = 'Flutter Outline',
          highlight = 'PanelHeading',
        },
        {
          filetype = 'packer',
          text = 'Packer',
          highlight = 'PanelHeading',
          padding = 1,
        },
      },
      groups = {
        options = {
          toggle_hidden_on_enter = true,
        },
        items = {
          {
            highlight = { guisp = '#51AFEF', gui = 'underline' },
            name = 'tests',
            matcher = function(buf)
              return buf.filename:match '_spec' or buf.filename:match 'test'
            end,
          },
          {
            name = 'View models',
            matcher = function(buf)
              return buf.filename:match 'view_model%.dart'
            end,
          },
          {
            name = 'Screens',
            matcher = function(buf)
              return buf.path:match 'screen'
            end,
          },
          {
            highlight = { guisp = '#C678DD', gui = 'underline' },
            name = 'docs',
            matcher = function(buf)
              return buf.path:match '%.md' or buf.path:match '%.txt'
            end,
          },
          {
            name = 'Build',
            matcher = function(buf)
              local ft = vim.api.nvim_buf_get_option(buf.id, 'filetype')
              return vim.tbl_contains({ 'log', 'yaml', 'json' }, ft)
            end,
          },
        },
      },
    },
  }

  require('which-key').register {
    ['gD'] = { '<Cmd>BufferLinePickClose<CR>', 'bufferline: delete buffer' },
    ['gb'] = { '<Cmd>BufferLinePick<CR>', 'bufferline: pick buffer' },
    ['<leader><tab>'] = { '<Cmd>BufferLineCycleNext<CR>', 'bufferline: next' },
    ['<S-tab>'] = { '<Cmd>BufferLineCyclePrev<CR>', 'bufferline: prev' },
    ['[b'] = { '<Cmd>BufferLineMoveNext<CR>', 'bufferline: move next' },
    [']b'] = { '<Cmd>BufferLineMovePrev<CR>', 'bufferline: move prev' },
    ['<leader>1'] = { '<Cmd>BufferLineGoToBuffer 1<CR>', 'bufferline: goto 1' },
    ['<leader>2'] = { '<Cmd>BufferLineGoToBuffer 2<CR>', 'bufferline: goto 2' },
    ['<leader>3'] = { '<Cmd>BufferLineGoToBuffer 3<CR>', 'bufferline: goto 3' },
    ['<leader>4'] = { '<Cmd>BufferLineGoToBuffer 4<CR>', 'bufferline: goto 4' },
    ['<leader>5'] = { '<Cmd>BufferLineGoToBuffer 5<CR>', 'bufferline: goto 5' },
    ['<leader>6'] = { '<Cmd>BufferLineGoToBuffer 6<CR>', 'bufferline: goto 6' },
    ['<leader>7'] = { '<Cmd>BufferLineGoToBuffer 7<CR>', 'bufferline: goto 7' },
    ['<leader>8'] = { '<Cmd>BufferLineGoToBuffer 8<CR>', 'bufferline: goto 8' },
    ['<leader>9'] = { '<Cmd>BufferLineGoToBuffer 9<CR>', 'bufferline: goto 9' },
  }
end
