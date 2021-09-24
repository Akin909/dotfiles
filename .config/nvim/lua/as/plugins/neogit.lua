local M = {}

function M.setup()
  require('which-key').register {
    ['<localleader>g'] = {
      s = 'neogit: open status buffer',
      c = 'neogit: open commit buffer',
      l = 'neogit: open pull popup',
      p = 'neogit: open push popup',
    },
  }
end

function M.config()
  local neogit = require 'neogit'
  neogit.setup {
    disable_signs = false,
    disable_commit_confirmation = true,
    disable_builtin_notifications = true,
    disable_insert_on_commit = false,
    signs = {
      section = { '', '' }, -- "", ""
      item = { '▸', '▾' },
      hunk = { '樂', '' },
    },
    integrations = {
      diffview = true,
    },
  }
  as.nnoremap('<localleader>gs', function()
    neogit.open()
  end)
  as.nnoremap('<localleader>gc', function()
    neogit.open { 'commit' }
  end)
  as.nnoremap('<localleader>gl', neogit.popups.pull.create)
  as.nnoremap('<localleader>gp', neogit.popups.push.create)

  local a = require 'plenary.async_lib'

  as.command {
    'NeogitOpenPr',
    function()
      a.scope(function()
        local fmt = string.format
        local remote_url = a.await(neogit.cli.config.get('remote.origin.url').call())
        local repo_name = remote_url:sub(16, -5)
        local branch = neogit.repo.head.branch
        local services = {
          github = {
            pr_url = [["https://github.com/%s/pull/new/%s"]],
          },
          gitlab = {
            pr_url = [["https://gitlab.com/%s/merge_requests/new?merge_request[source_branch]=%s"]],
          },
        }

        local cmd = neogit.cli['show-ref'].verify.show_popup(false).args(remote_url)
        local output = a.await(cmd.call())
        if output == '' then
          return vim.schedule(function()
            vim.notify(fmt("%s doesn't exist in the remote, please push the branch first", branch))
          end)
        end

        local current
        for service, _ in pairs(services) do
          if remote_url:match(service) then
            current = service
            break
          end
        end
        if not current then
          return vim.notify(fmt('No supported service for %s', remote_url))
        end
        local open_pr_url = fmt(services[current].pr_url, repo_name, branch)

        a.await(a.scheduler())
        if as.has 'mac' then
          vim.cmd('silent !open ' .. open_pr_url)
        elseif as.has 'unix' then
          vim.cmd('silent !xdg-open ' .. open_pr_url)
        end
      end)
    end,
  }
end

return M
