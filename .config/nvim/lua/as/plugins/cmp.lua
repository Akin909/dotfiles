return function()
  local api = vim.api
  local t = as.replace_termcodes
  local cmp = require 'cmp'
  local fmt = string.format

  require('as.highlights').plugin(
    'Cmp',
    { 'CmpItemAbbr', { inherit = 'Comment', gui = 'NONE' } },
    { 'CmpItemMenu', { inherit = 'NonText', gui = 'NONE' } },
    { 'CmpItemAbbrMatch', { inherit = 'Pmenu', gui = 'bold' } },
    { 'CmpItemAbbrDeprecated', { gui = 'strikethrough', inherit = 'Comment' } },
    { 'CmpItemAbbrMatchFuzzy', { gui = 'italic', guifg = 'fg' } }
  )

  local lsp_hls = as.style.lsp.kind_highlights

  local kind_hls = vim.tbl_map(function(key)
    return { fmt('CmpItemKind%s', key), { inherit = lsp_hls[key], gui = 'NONE' } }
  end, vim.tbl_keys(lsp_hls))

  require('as.highlights').plugin('CmpKinds', unpack(kind_hls))

  local function feed(key, mode)
    api.nvim_feedkeys(t(key), mode or '', true)
  end

  local function get_luasnip()
    local ok, luasnip = as.safe_require('luasnip', { silent = true })
    if not ok then
      return nil
    end
    return luasnip
  end

  local function tab(fallback)
    local luasnip = get_luasnip()
    local copilot_keys = vim.fn['copilot#Accept']()
    if cmp.visible() then
      cmp.select_next_item()
    elseif copilot_keys ~= '' then -- prioritise copilot over snippets
      -- Copilot keys do not need to be wrapped in termcodes
      api.nvim_feedkeys(copilot_keys, 'i', true)
    elseif luasnip and luasnip.expand_or_locally_jumpable() then
      luasnip.expand_or_jump()
    elseif api.nvim_get_mode().mode == 'c' then
      fallback()
    else
      feed '<Plug>(Tabout)'
    end
  end

  local function shift_tab(fallback)
    local luasnip = get_luasnip()
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    elseif api.nvim_get_mode().mode == 'c' then
      fallback()
    else
      local copilot_keys = vim.fn['copilot#Accept']()
      if copilot_keys ~= '' then
        feed(copilot_keys, 'i')
      else
        feed '<Plug>(Tabout)'
      end
    end
  end

  cmp.setup {
    experimental = {
      ghost_text = false, -- disable whilst using copilot
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<Tab>'] = cmp.mapping(tab, { 'i', 'c' }),
      ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 'c' }),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-q>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
    },
    formatting = {
      deprecated = true,
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, vim_item)
        vim_item.kind = as.style.lsp.kinds[vim_item.kind]
        local name = entry.source.name
        local completion = entry.completion_item.data
        -- FIXME: automate this using a regex to normalise names
        local menu = ({
          nvim_lsp = '[LSP]',
          nvim_lua = '[Lua]',
          emoji = '[Emoji]',
          path = '[Path]',
          calc = '[Calc]',
          neorg = '[Neorg]',
          orgmode = '[Org]',
          cmp_tabnine = '[TN]',
          luasnip = '[Luasnip]',
          buffer = '[Buffer]',
          spell = '[Spell]',
          cmdline = '[Command]',
          cmp_git = '[Git]',
        })[name]

        if name == 'cmp_tabnine' then
          if completion and completion.detail then
            menu = completion.detail .. ' ' .. menu
          end
          vim_item.kind = ''
        end
        vim_item.menu = menu
        return vim_item
      end,
    },
    documentation = {
      border = 'rounded',
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'cmp_tabnine' },
      { name = 'spell' },
      { name = 'path' },
      { name = 'neorg' },
      { name = 'orgmode' },
      { name = 'cmp_git' },
    }, {
      { name = 'buffer' },
    }),
  }

  local search_sources = {
    sources = cmp.config.sources({
      { name = 'nvim_lsp_document_symbol' },
    }, {
      { name = 'buffer' },
    }),
  }
  cmp.setup.cmdline('/', search_sources)
  cmp.setup.cmdline('?', search_sources)
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources {
      { name = 'cmdline' },
    },
  })
end
