return {
  'chentoast/marks.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function()
    require('marks').setup {
      default_mappings = false,
      mappings = {
        set_next = 'm,',
        next = '<C-j>',
        prev = '<C-k>',
        set_bookmark1 = 'm1',
        next_bookmark1 = '<C-n>',
        preview = 'm:',
        prev_bookmark1 = '<C-p>',
        delete_buf = 'dm<leader>',
      },
    }
  end,
}
