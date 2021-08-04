local fn = vim.fn
local t = as.replace_termcodes

local check_back_space = function()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

--- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.__tab_complete = function()
  if fn.pumvisible() == 1 then
    return t '<C-n>'
  elseif fn['vsnip#available'](1) == 1 then
    return t '<Plug>(vsnip-expand-or-jump)'
  elseif check_back_space() then
    return t '<Tab>'
  else
    return fn['compe#complete']()
  end
end
_G.__s_tab_complete = function()
  if fn.pumvisible() == 1 then
    return t '<C-p>'
  elseif fn['vsnip#jumpable'](-1) == 1 then
    return t '<Plug>(vsnip-jump-prev)'
  else
    return t '<S-Tab>'
  end
end

return function()
  require('compe').setup {
    source = {
      path = true,
      buffer = { kind = ' ' },
      vsnip = { kind = ' ' },
      spell = true,
      emoji = { kind = 'ﲃ', filetypes = { 'markdown', 'gitcommit' } },
      nvim_lsp = { priority = 101 },
      nvim_lua = true,
      orgmode = true,
      neorg = true,
    },
    documentation = {
      border = 'rounded',
      winhighlight = table.concat({
        'NormalFloat:CompeDocumentation',
        'Normal:CompeDocumentation',
        'FloatBorder:CompeDocumentationBorder',
      }, ','),
    },
  }

  local imap = as.imap
  local smap = as.smap
  local inoremap = as.inoremap
  local opts = { expr = true, silent = true }

  inoremap('<C-e>', 'compe#complete()', opts)
  imap('<Tab>', 'v:lua.__tab_complete()', opts)
  smap('<Tab>', 'v:lua.__tab_complete()', opts)
  imap('<S-Tab>', 'v:lua.__s_tab_complete()', opts)
  smap('<S-Tab>', 'v:lua.__s_tab_complete()', opts)
  inoremap('<C-f>', "compe#scroll({ 'delta': +4 })", opts)
  inoremap('<C-d>', "compe#scroll({ 'delta': -4 })", opts)
end
