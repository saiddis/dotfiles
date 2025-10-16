return {
  'chentoast/marks.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function()
    require('marks').setup {
      default_mappings = false,
      mappings = {
        next = '<C-j>',
        prev = '<C-k>',
        delete_buf = 'dm',
        delete_line = '<C-m>',

        set_bookmark1 = 'm1',
        delete_bookmark1 = 'd1',
        next_bookmark1 = '<C-n>',
        prev_bookmark1 = '<C-p>',

        preview = 'm:',
        set_next = 'm,',
      },
    }
  end,
}
