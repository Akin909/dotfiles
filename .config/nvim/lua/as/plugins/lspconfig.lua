as.lsp = {}
-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//
local function setup_autocommands(client, _)
  as.augroup(
    "LspLocationList",
    {
      {
        events = {"InsertLeave", "BufWrite", "BufEnter"},
        targets = {"<buffer>"},
        command = [[lua vim.lsp.diagnostic.set_loclist({open_loclist = false})]]
      }
    }
  )
  if client and client.resolved_capabilities.document_highlight then
    as.augroup(
      "LspCursorCommands",
      {
        {
          events = {"CursorHold"},
          targets = {"<buffer>"},
          command = "lua vim.lsp.buf.document_highlight()"
        },
        {
          events = {"CursorHoldI"},
          targets = {"<buffer>"},
          command = "lua vim.lsp.buf.document_highlight()"
        },
        {
          events = {"CursorMoved"},
          targets = {"<buffer>"},
          command = "lua vim.lsp.buf.clear_references()"
        }
      }
    )
  end
  if client and client.resolved_capabilities.document_formatting then
    -- format on save
    as.augroup(
      "LspFormat",
      {
        {
          events = {"BufWritePre"},
          targets = {"<buffer>"},
          command = "lua vim.lsp.buf.formatting_sync(nil, 5000)"
        }
      }
    )
  end
end
-----------------------------------------------------------------------------//
-- Mappings
-----------------------------------------------------------------------------//
local function setup_mappings(client, bufnr)
  -- check that there are no existing mappings before assigning these
  local nnoremap, vnoremap, opts = as.nnoremap, as.vnoremap, {buffer = bufnr, check_existing = true}

  nnoremap("gd", vim.lsp.buf.definition, opts)
  if client.resolved_capabilities.implementation then
    nnoremap("gi", vim.lsp.buf.implementation, opts)
  end

  if client.resolved_capabilities.type_definition then
    nnoremap("<leader>gd", vim.lsp.buf.type_definition, opts)
  end

  nnoremap("<leader>ca", vim.lsp.buf.code_action, opts)
  vnoremap("<leader>ca", vim.lsp.buf.range_code_action, opts)

  nnoremap(
    "]c",
    function()
      vim.lsp.diagnostic.goto_prev {popup_opts = {border = "single"}}
    end,
    opts
  )

  nnoremap(
    "[c",
    function()
      vim.lsp.diagnostic.goto_next {popup_opts = {border = "single"}}
    end,
    opts
  )

  nnoremap("K", vim.lsp.buf.hover, opts)
  nnoremap("gI", vim.lsp.buf.incoming_calls, opts)
  nnoremap("gr", vim.lsp.buf.references, opts)
  nnoremap("<leader>rn", vim.lsp.buf.rename, opts)
  nnoremap("<leader>cs", vim.lsp.buf.document_symbol, opts)
  nnoremap("<leader>cw", vim.lsp.buf.workspace_symbol, opts)
  nnoremap("<leader>rf", vim.lsp.buf.formatting, opts)
  require("which-key").register(
    {
      ["<leader>rf"] = "lsp: format buffer",
      ["gr"] = "lsp: references"
    }
  )
end

function as.lsp.tagfunc(pattern, flags)
  if flags ~= "c" then
    return vim.NIL
  end
  local params = vim.lsp.util.make_position_params()
  local client_id_to_results, err =
    vim.lsp.buf_request_sync(0, "textDocument/definition", params, 500)
  assert(not err, vim.inspect(err))

  local results = {}
  for _, lsp_results in ipairs(client_id_to_results) do
    for _, location in ipairs(lsp_results.result or {}) do
      local start = location.range.start
      table.insert(
        results,
        {
          name = pattern,
          filename = vim.uri_to_fname(location.uri),
          cmd = string.format("call cursor(%d, %d)", start.line + 1, start.character + 1)
        }
      )
    end
  end
  return results
end

require("vim.lsp.protocol").CompletionItemKind = {
  " (Text)", -- Text
  " (Method)", -- Method
  "ƒ (Function)", -- Function
  " (Constructor)", -- Constructor
  "識 (Field)", -- Field
  " (Variable)", -- Variable
  "\u{f0e8} (Class)", -- Class
  "ﰮ (Interface)", -- Interface
  " (Module)", -- Module
  " (Property)", -- Property
  " (Unit)", -- Unit
  " (Value)", -- Value
  "了 (Enum)", -- Enum
  " (Keyword)", -- Keyword
  " (Snippet)", -- Snippet
  " (Color)", -- Color
  " (File)", -- File
  "渚 (Reference)", -- Reference
  " (Folder)", -- Folder
  " (Enum)", -- Enum
  " (Constant)", -- Constant
  " (Struct)", -- Struct
  "鬒 (Event)", -- Event
  "\u{03a8} (Operator)", -- Operator
  " (Type Parameter)" -- TypeParameter
}

function as.lsp.on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = "v:lua.as.lsp.tagfunc"
  end
  require("lsp-status").on_attach(client)
end

-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//

--- This function if called immediately on startup might not have all the correct
--- paths added to the runtime if the the package manager e.g. packer loads things too late
local function get_lua_runtime()
  local library = {}
  local items = {
    "$VIMRUNTIME",
    "$DOTFILES",
    "~/.local/share/nvim/site/pack/packer/opt/*",
    "~/.local/share/nvim/site/pack/packer/start/*"
  }
  for _, item in ipairs(items) do
    for _, p in pairs(vim.fn.expand(item, false, true)) do
      p = vim.loop.fs_realpath(p)
      library[p] = true
    end
  end
  return library
end

--- LSP server configs are setup dynamically as they need to be generated during
--- startup so things like runtimepath for lua is correctly populated
as.lsp.servers = {
  lua = function()
    --- NOTE: This is the secret sauce that allows reading requires and variables
    --- between different modules in the nvim lua context
    --- @see https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8
    local path = vim.split(package.path, ";")
    table.insert(path, "lua/?.lua")
    table.insert(path, "lua/?/init.lua")
    local library = get_lua_runtime()
    return {
      -- delete root from workspace to make sure we don't trigger duplicate warnings
      on_new_config = function(config, root)
        local libs = vim.deepcopy(library)
        libs[root] = nil
        config.settings.Lua.workspace.library = libs
        return config
      end,
      settings = {
        Lua = {
          diagnostics = {
            globals = {"vim", "describe", "it", "before_each", "after_each", "pending"}
          },
          completion = {keywordSnippet = "Both", callSnippet = "Both"},
          runtime = {
            version = "LuaJIT",
            path = path
          },
          workspace = {
            maxPreload = 2000,
            preloadFileSize = 50000,
            library = library
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {enable = false}
        }
      }
    }
  end,
  diagnosticls = function()
    return {
      rootMarkers = {".git/"},
      filetypes = {"yaml", "json", "html", "css", "markdown", "lua", "graphql"},
      init_options = {
        formatters = {
          prettier = {
            rootPatterns = {".git"},
            command = "prettier",
            args = {"--stdin-filepath", "%filename"}
          },
          luaformatter = {
            -- 'lua-format -i -c {config_dir}'
            -- add ".lua-format" to root if using lua-format
            rootPatterns = {".git"},
            command = "lua-format",
            args = {"-i", "-c", "./.lua-format"}
          },
          luafmt = {
            -- npm i -g lua-fmt
            rootPatterns = {".git"},
            command = "luafmt",
            args = {"--indent-count", vim.o.shiftwidth, "--line-width", "100", "--stdin"}
          },
          stylua = {
            rootPatterns = {".git"},
            command = "stylua",
            args = {"--config-path", vim.g.vim_dir .. "/stylua.toml", "-"}
          }
        },
        formatFiletypes = {
          json = "prettier",
          html = "prettier",
          css = "prettier",
          yaml = "prettier",
          markdown = "prettier",
          graphql = "prettier",
          lua = "luafmt"
        }
      }
    }
  end
}

function as.lsp.setup_servers()
  vim.cmd("packadd nvim-lspinstall") -- Important!
  local lspinstall = require("lspinstall")
  local lspconfig = require("lspconfig")

  lspinstall.setup()
  local installed = lspinstall.installed_servers()
  local status_capabilities = require("lsp-status").capabilities
  for _, server in pairs(installed) do
    local mk_config = as.lsp.servers[server]
    local config = mk_config and mk_config() or {}
    config.flags = config.flags or {}
    config.flags.debounce_text_changes = 150
    config.on_attach = as.lsp.on_attach
    if not config.capabilities then
      config.capabilities = vim.lsp.protocol.make_client_capabilities()
    end
    config.capabilities.textDocument.completion.completionItem.snippetSupport = true
    config.capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits"
      }
    }
    config.capabilities = as.deep_merge(config.capabilities, status_capabilities)
    lspconfig[server].setup(config)
  end
end

-----------------------------------------------------------------------------//
-- Commands
-----------------------------------------------------------------------------//
local command = as.command

command {
  "LspLog",
  function()
    local path = vim.lsp.get_log_path()
    vim.cmd("edit " .. path)
  end
}

command {
  "Format",
  function()
    vim.lsp.buf.formatting_sync(nil, 1000)
  end
}

return function()
  if vim.g.lspconfig_has_setup then
    return
  end
  vim.g.lspconfig_has_setup = true

  vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)

  -----------------------------------------------------------------------------//
  -- Signs
  -----------------------------------------------------------------------------//
  vim.fn.sign_define(
    {
      {name = "LspDiagnosticsSignError", text = "✗", texthl = "LspDiagnosticsSignError"},
      {name = "LspDiagnosticsSignHint", text = "", texthl = "LspDiagnosticsSignHint"},
      {name = "LspDiagnosticsSignWarning", text = "", texthl = "LspDiagnosticsSignWarning"},
      {name = "LspDiagnosticsSignInformation", text = "", texthl = "LspDiagnosticsSignInformation"}
    }
  )

  -----------------------------------------------------------------------------//
  -- Handler overrides
  -----------------------------------------------------------------------------//
  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      underline = true,
      virtual_text = false,
      signs = true,
      update_in_insert = false
    }
  )

  -- NOTE: the hover handler returns the bufnr,winnr so can be use for mappings
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "single"})

  as.lsp.setup_servers()
end
