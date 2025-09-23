return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    local mocha = require('catppuccin.palettes').get_palette 'mocha'
    mocha.base = '#000000'
    mocha.mantle = '#1b1b28'
    mocha.crust = '#141421'

    mocha.text = '#f8f8f2'
    mocha.subtext1 = '#e4e4f0'
    mocha.subtext0 = '#cfcfe5'
    mocha.overlay2 = '#b8bad9'
    mocha.overlay1 = '#a1a3c7'
    mocha.overlay0 = '#8a8db4'

    mocha.surface2 = '#6e7191'
    mocha.surface1 = '#565978'
    mocha.surface0 = '#3e405a'

    mocha.red = '#ff5555'
    mocha.maroon = '#ff6e6e'
    mocha.peach = '#ffb86c'
    mocha.yellow = '#f1fa8c'
    mocha.green = '#50fa7b'
    mocha.teal = '#4dffff'
    mocha.sky = '#8be9fd'
    mocha.sapphire = '#5ad6ff'
    mocha.blue = '#6272a4'
    mocha.lavender = '#9ea0ff'
    mocha.mauve = '#bd93f9'
    mocha.pink = '#ff79c6'
    mocha.flamingo = '#ff99aa'
    require('catppuccin').setup {
      flavour = 'auto', -- latte, frappe, macchiato, mocha
      background = { -- :h background
        light = 'latte',
        dark = 'mocha',
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
      term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = 'dark',
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
      },
      no_italic = false, -- Force no italic
      no_bold = false, -- Force no bold
      no_underline = false, -- Force no underline
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { 'italic' }, -- Change the style of comments
        conditionals = { 'italic' },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      color_overrides = {
        mocha = {
          base = '#000000',
          mantle = '#1b1b28',
          crust = '#141421',

          text = '#f8f8f2',
          subtext1 = '#e4e4f0',
          subtext0 = '#cfcfe5',
          -- overlay2 = '#b8bad9',
          -- overlay1 = '#a1a3c7',
          -- overlay0 = '#8a8db4',

          -- surface2 = '#6e7191',
          -- surface1 = '#565978',
          -- surface0 = '#3e405a',

          red = '#ff5555',
          maroon = '#ff6e6e',
          peach = '#ffb86c',
          yellow = '#f1fa8c',
          green = '#50fa7b', -- Dracula green
          teal = '#4dffff',
          sky = '#8be9fd',
          sapphire = '#5ad6ff',
          -- blue      = '#6272a4',
          lavender = '#9ea0ff',
          mauve = '#bd93f9', -- Dracula purple
          pink = '#ff79c6', -- Dracula pink
          flamingo = '#ff99aa',
          aqua = '#66ffe0',
        },
      },
      custom_highlights = {
        TelescopeMatching = { fg = mocha.pink },
        TelescopeSelection = { fg = mocha.mauve, bg = mocha.surface0, bold = true },
        TelescopePromptPrefix = { bg = mocha.base },
        TelescopePromptNormal = { bg = mocha.base },
        TelescopeResultsNormal = { bg = mocha.base },
        TelescopePreviewNormal = { bg = mocha.base },
        TelescopePromptBorder = { bg = mocha.base, fg = mocha.green },
        TelescopeResultsBorder = { bg = mocha.base, fg = mocha.green },
        TelescopePreviewBorder = { bg = mocha.base, fg = mocha.green },
        TelescopePromptTitle = { fg = mocha.pink },
        TelescopeResultsTitle = { fg = mocha.pink },
        TelescopePreviewTitle = { fg = mocha.pink },

        -- GitSignsAdd = { fg = colors.lime, bg = colors.black, bold = true },
        -- GitSignsChange = { fg = colors.violet, bg = colors.black, bold = true },
        -- GitSignsDelete = { fg = colors.crimson, bg = colors.black, bold = true },
        -- GitSignsTopDelete = { fg = colors.crimson, bg = colors.black, bold = true },
        -- GitSignsChangeDelete = { fg = colors.orange, bg = colors.black, bold = true },
        -- GitSignsUntracked = { fg = colors.turquoise, bg = colors.black, bold = true },
        -- GitSignsCurrentLineBlame = { fg = colors.crimson, bg = colors.black, bold = true },

        -- FloatBorder = { bg = mocha.base, fg = mocha.surface1 },
        -- CursorLineNr = { bg = mocha.overlay0, fg = mocha.green, bold = true },
        -- CursorLine = { bg = mocha.overlay0, bold = false },
        -- LineNr = { fg = mocha.surface2, bg = mocha.surface0 },
        -- SignColumn = { fg = mocha.surface2, bg = mocha.surface0 },
        -- Directory = { fg = mocha.green, bold = true },
        -- NormalFloat = { bg = mocha.base },
      },
      default_integrations = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = '',
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      },
    }

    -- setup must be called before loading
    vim.cmd.colorscheme 'catppuccin'
  end,
}
