return {
  'monkoose/nvlime',
  dependencies = {
    'monkoose/parsley',
  },

  config = function()
    vim.g.nvlime_config = {
      cmp = { enabled = true },

      compiler_policy = { DEBUG = 3 },
    }
  end,
}
