return {
  'saghen/blink.cmp',
  dependencies = {
    {
      'supermaven-inc/supermaven-nvim',
      opts = {
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
      },
    },
    {
      'huijiro/blink-cmp-supermaven',
    },
  },
  opts = {
    sources = {
      default = { 'lsp', 'path', 'supermaven', 'snippets', 'buffer' },
      providers = {
        supermaven = {
          name = 'supermaven',
          module = 'blink-cmp-supermaven',
          async = true,
        },
      },
    },
  },
}
