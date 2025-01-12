local highlight, ui = as.highlight, as.ui
local fn = vim.fn
local border = ui.current.border

return {
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    init = function()
      highlight.plugin('blink', {
        { BlinkCmpMenuBorder = { link = 'PickerBorder' } },
        { BlinkCmpDocBorder = { link = 'PickerBorder' } },
        { BlinkCmpMenu = { link = 'Normal' } },
      })
    end,
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'enter' },
      appearance = { nerd_font_variant = 'mono', use_nvim_cmp_as_default = true },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          markdown = {
            name = 'RenderMarkdown',
            module = 'render-markdown.integ.blink',
            fallbacks = { 'lsp' },
          },
        },
      },
      signature = { window = { border = border } },
      completion = {
        menu = { border = border },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = { border = border },
        },
        list = {
          selection = {
            auto_insert = function(ctx) return ctx.mode == 'cmdline' and false or true end,
          },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    init = function() vim.g.copilot_no_tab_map = true end,
    config = function()
      local function accept_word()
        fn['copilot#Accept']('')
        local output = fn['copilot#TextQueuedForInsertion']()
        return fn.split(output, [[[ .]\zs]])[1]
      end

      local function accept_line()
        fn['copilot#Accept']('')
        local output = fn['copilot#TextQueuedForInsertion']()
        return fn.split(output, [[[\n]\zs]])[1]
      end
      map('i', '<Plug>(as-copilot-accept)', "copilot#Accept('<Tab>')", {
        expr = true,
        remap = true,
        silent = true,
      })
      map('i', '<M-]>', '<Plug>(copilot-next)', { desc = 'next suggestion' })
      map('i', '<M-[>', '<Plug>(copilot-previous)', { desc = 'previous suggestion' })
      map('i', '<C-\\>', '<Cmd>vertical Copilot panel<CR>', { desc = 'open copilot panel' })
      map('i', '<M-w>', accept_word, { expr = true, remap = false, desc = 'accept word' })
      map('i', '<M-l>', accept_line, { expr = true, remap = false, desc = 'accept line' })
      vim.g.copilot_filetypes = {
        ['*'] = true,
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      }
      highlight.plugin('copilot', { { CopilotSuggestion = { link = 'Comment' } } })
    end,
  },
}
