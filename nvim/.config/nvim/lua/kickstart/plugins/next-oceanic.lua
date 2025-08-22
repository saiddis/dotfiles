return {
  'mhartington/oceanic-next',
  name = 'oceanic-next',
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd [[hi Normal guibg=NONE ctermbg=NONE]]
    vim.cmd [[colorscheme OceanicNext]]
  end,
}
