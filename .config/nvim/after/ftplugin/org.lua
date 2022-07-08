vim.opt_local.spell = true

as.ftplugin_conf(
  'cmp',
  function(cmp)
    cmp.setup.filetype('org', {
      sources = cmp.config.sources({
        { name = 'orgmode' },
        { name = 'dictionary' },
        { name = 'spell' },
        { name = 'emoji' },
      }, {
        { name = 'buffer' },
      }),
    })
  end
)
