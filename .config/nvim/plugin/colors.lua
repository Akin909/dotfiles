if not as then return end
local P = as.ui.palette
local highlight = as.highlight

local function general_overrides()
  local is_dark = vim.g.high_contrast_theme
  local dim_factor = is_dark and 0.75 or 0.25
  highlight.all({
    -----------------------------------------------------------------------------//
    -- Native
    -----------------------------------------------------------------------------//
    { VertSplit = { fg = { from = 'Comment' } } },
    { WinSeparator = { fg = { from = 'Comment' } } },
    { CursorLine = { bg = { from = 'Normal', alter = dim_factor } } },
    { CursorLineNr = { bg = 'NONE' } },
    { iCursor = { bg = P.dark_blue } },
    { PmenuSbar = { link = 'Normal' } },
    { Folded = { bg = 'NONE', fg = { from = 'Normal', alter = -0.80 } } },
    --------------------------------------------//
    -- Floats
    ---------------------------------------------//
    { NormalFloat = { bg = { from = 'Normal', alter = -0.15 } } },
    { FloatBorder = { bg = { from = 'NormalFloat' }, fg = { from = 'Comment' } } },
    { FloatTitle = { bold = true, fg = 'white', bg = { from = 'Comment', attr = 'fg' } } },
    -----------------------------------------------------------------------------//
    -- Created highlights
    -----------------------------------------------------------------------------//
    { Dim = { fg = { from = 'Normal', attr = 'bg', alter = dim_factor } } },
    { PickerBorder = { fg = P.grey, bg = 'bg' } },
    { PickerTitle = { fg = 'white', bg = P.grey, bold = true } },
    { UnderlinedTitle = { bold = true, underline = true } },
    { StatusColSep = { link = 'Dim' } },
    -----------------------------------------------------------------------------//
    { CodeBlock = { bg = { from = 'Normal', alter = 0.3 } } },
    { markdownCode = { link = 'CodeBlock' } },
    { markdownCodeBlock = { link = 'CodeBlock' } },
    -----------------------------------------------------------------------------//
    --  Spell
    -----------------------------------------------------------------------------//
    { SpellBad = { undercurl = true, bg = 'NONE', fg = 'NONE', sp = 'green' } },
    { SpellRare = { undercurl = true } },
    -----------------------------------------------------------------------------//
    -- Diff
    -----------------------------------------------------------------------------//
    -- { DiffAdd = { bg = '#26332c', fg = 'NONE', underline = false } },
    -- { DiffDelete = { bg = '#572E33', fg = '#5c6370', underline = false } },
    -- { DiffChange = { bg = '#273842', fg = 'NONE', underline = false } },
    -- { DiffText = { bg = '#314753', fg = 'NONE' } },
    -- these highlights are syntax groups that are set in diff.vim
    { diffAdded = { inherit = 'DiffAdd' } },
    { diffChanged = { inherit = 'DiffChange' } },
    { diffRemoved = { link = 'DiffDelete' } },
    { diffBDiffer = { link = 'WarningMsg' } },
    { diffCommon = { link = 'WarningMsg' } },
    { diffDiffer = { link = 'WarningMsg' } },
    { diffFile = { link = 'Directory' } },
    { diffIdentical = { link = 'WarningMsg' } },
    { diffIndexLine = { link = 'Number' } },
    { diffIsA = { link = 'WarningMsg' } },
    { diffNoEOL = { link = 'WarningMsg' } },
    { diffOnly = { link = 'WarningMsg' } },
    -----------------------------------------------------------------------------//
    -- colorscheme overrides
    -----------------------------------------------------------------------------//
    { Type = { italic = true, bold = true } },
    { Include = { italic = true, bold = false } },
    { QuickFixLine = { inherit = 'CursorLine', fg = 'NONE', italic = true } },
    -- Neither the sign column or end of buffer highlights require an explicit bg
    -- they should both just use the bg that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { bg = 'NONE' } },
    { EndOfBuffer = { bg = 'NONE' } },
    ------------------------------------------------------------------------------//
    --  Semantic tokens
    ------------------------------------------------------------------------------//
    { ['@lsp.type.parameter'] = { italic = true, fg = { from = 'Normal' } } },
    { ['@lsp.typemod.method'] = { link = '@method' } },
    { ['@lsp.typemod.variable.global'] = { bold = true, inherit = '@constant.builtin' } },
    { ['@lsp.typemod.variable.defaultLibrary'] = { italic = true } },
    { ['@lsp.typemod.number.injected'] = { link = '@number' } },
    { ['@lsp.typemod.operator.injected'] = { link = '@operator' } },
    { ['@lsp.typemod.keyword.injected'] = { link = '@keyword' } },
    { ['@lsp.typemod.string.injected'] = { link = '@string' } },
    { ['@lsp.typemod.variable.injected'] = { link = '@variable' } },
    -----------------------------------------------------------------------------//
    -- Treesitter
    -----------------------------------------------------------------------------//
    { ['@keyword.return'] = { italic = true, fg = { from = 'Keyword' } } },
    { ['@type.qualifier'] = { inherit = '@keyword', italic = true } },
    { ['@parameter'] = { italic = true, bold = true, fg = 'NONE' } },
    { ['@error'] = { fg = 'fg', bg = 'NONE' } },
    { ['@text.diff.add'] = { link = 'DiffAdd' } },
    { ['@text.diff.delete'] = { link = 'DiffDelete' } },
    { ['@text.title.markdown'] = { underdouble = true } },
    -----------------------------------------------------------------------------//
    -- LSP
    -----------------------------------------------------------------------------//
    { LspReferenceWrite = { inherit = 'LspReferenceText', bold = true, italic = true, underline = true } },
    { LspSignatureActiveParameter = { link = 'Visual' } },
    -- Sign column line
    { DiagnosticSignInfoLine = { inherit = 'DiagnosticVirtualTextInfo', fg = 'NONE' } },
    { DiagnosticSignHintLine = { inherit = 'DiagnosticVirtualTextHint', fg = 'NONE' } },
    { DiagnosticSignErrorLine = { inherit = 'DiagnosticVirtualTextError', fg = 'NONE' } },
    { DiagnosticSignWarnLine = { inherit = 'DiagnosticVirtualTextWarn', fg = 'NONE' } },
    -- Floating windows
    { DiagnosticFloatingWarn = { link = 'DiagnosticWarn' } },
    { DiagnosticFloatingInfo = { link = 'DiagnosticInfo' } },
    { DiagnosticFloatingHint = { link = 'DiagnosticHint' } },
    { DiagnosticFloatingError = { link = 'DiagnosticError' } },
    { DiagnosticFloatTitle = { inherit = 'FloatTitle', bold = true } },
    { DiagnosticFloatTitleIcon = { inherit = 'FloatTitle', fg = { from = '@character' } } },
  })
end

local function set_sidebar_highlight()
  highlight.all({
    { PanelDarkBackground = { bg = { from = 'Normal', alter = -0.42 } } },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { bg = { from = 'Normal', alter = -0.8 } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    { PanelWinSeparator = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { bg = { from = 'Visual', alter = -0.2 } } },
  })
end

local sidebar_fts = {
  'flutterToolsOutline',
  'Avante',
  'AvanteInput',
  'undotree',
  'Outline',
  'dbui',
  'neotest-summary',
}

local function on_sidebar_enter()
  vim.opt_local.winhighlight:append({
    Normal = 'PanelBackground',
    EndOfBuffer = 'PanelBackground',
    StatusLine = 'PanelSt',
    StatusLineNC = 'PanelStNC',
    SignColumn = 'PanelBackground',
    VertSplit = 'PanelVertSplit',
    WinSeparator = 'PanelWinSeparator',
  })
end

local function colorscheme_overrides()
  local overrides = {
    ['horizon'] = {
      { Constant = { bold = true } },
      { NonText = { fg = { from = 'Comment' } } },
      { TabLineSel = { fg = { from = 'SpecialKey' } } },
      { ['@variable'] = { fg = { from = 'Normal' } } },
      { ['@constant.comment'] = { inherit = 'Constant', bold = true } },
      { ['@constructor.lua'] = { inherit = 'Type', italic = false, bold = false } },
      { ['@lsp.type.parameter'] = { fg = { from = 'Normal' } } },
      { ['@lsp.type.variable'] = { clear = true } },
      { ['@lsp.typemod.variable.readonly.typescriptreact'] = { clear = true } },
      { ['@lsp.typemod.variable.readonly.typescript'] = { clear = true } },
      { ['@lsp.type.type.lua'] = { clear = true } },
      { VisibleTab = { bg = { from = 'Normal', alter = 0.4 }, bold = true } },
      { PanelBackground = { link = 'Normal' } },
      { PanelWinSeparator = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
      { PanelHeading = { bg = 'bg', bold = true, fg = { from = 'Normal', alter = -0.3 } } },
      { PanelDarkBackground = { bg = { from = 'Normal', alter = -0.25 } } },
      { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    },
    ['github_dark_default'] = {
      { TabLineSel = { link = 'Todo' } },
      { WinSeparator = { link = 'WhiteSpace' } },
      { PanelHeading = { bg = { from = 'Normal', alter = 0.8 } } },
    },
  }
  local hls = overrides[vim.g.colors_name]
  if hls then highlight.all(hls) end
end

local function user_highlights()
  general_overrides()
  set_sidebar_highlight()
  colorscheme_overrides()
end

as.augroup('UserHighlights', {
  event = 'ColorScheme',
  command = function() user_highlights() end,
}, {
  event = 'FileType',
  pattern = sidebar_fts,
  command = function() on_sidebar_enter() end,
})
