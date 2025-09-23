return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  opts = {},

  config = function()
    require('tokyonight').setup {
      -- use the night style
      style = 'night',
      -- disable italic for functions
      styles = {
        functions = {},
      },
      -- Change the "hint" color to the "orange" color, and make the "error" color bright red
      on_colors = function(colors)
        colors.bg = '#000000'
        colors.error = '#ff0000'
      end,

      on_highlights = function(hl, c) end,
    }

    -- local colors = require('tokyonightcolors').setup() -- pass in any of the config options as explained above
    vim.cmd [[colorscheme tokyonight]]
  end,
}
