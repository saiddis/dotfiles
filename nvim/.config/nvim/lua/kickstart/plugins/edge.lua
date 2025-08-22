return {
  'sainnhe/edge',
  lazy = false,
  priority = 1000,
  config = function()
    -- Optionally configure and load the colorscheme
    -- directly inside the plugin declaration.
    vim.g.edge_enable_italic = true
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('custom_highlights_edge', {}),
      pattern = 'edge',
      callback = function()
        local config = vim.fn['edge#get_configuration']()
        local palette = vim.fn['edge#get_palette'](config.style, config.dim_foreground, config.colors_override)
        local set_hl = vim.fn['edge#highlight']

        -- set_hl('Normal', '#000000', '#000000')
        set_hl('Search', palette.none, palette.diff_blue)
        set_hl('IncSearch', palette.none, palette.diff_green)
      end,
    })
    -- vim.cmd [[let g:edge_style = 'neon']]
    vim.cmd [[let g:edge_colors_override = {'bg0': ['#000000', '234'],'bg1':['#282828', '235'], 'bg2': ['#282828', '235'], 'gray_dim':['#000000','235']}]]
    vim.cmd.colorscheme 'edge'
  end,
}
