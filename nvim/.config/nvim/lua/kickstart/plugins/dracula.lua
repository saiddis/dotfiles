return {
  -- add dracula
  'Mofiqul/dracula.nvim',
  name = 'dracula',
  lazy = false,
  priority = 1000,

  config = function()
    local colors = require('dracula').colors()

    colors.bg = '#000000'
    colors.nontext = colors.black
    colors.black = '#080808'
    colors.gutter_fg = '#314940'
    -- colors.selection = '#262626'
    -- colors.black = '#4a4c50'

    local dracula = require 'dracula'
    dracula.setup {
      -- customize dracula color palette
      colors = {
        bg = colors.bg,
        fg = colors.fg,
        selection = colors.selection,
        comment = colors.comment,
        red = colors.red,
        orange = colors.orange,
        yellow = colors.yellow,
        green = colors.green,
        purple = colors.purple,
        cyan = colors.cyan,
        pink = colors.pink,
        bright_red = colors.bright_red,
        bright_green = colors.bright_green,
        bright_yellow = colors.bright_yellow,
        bright_blue = colors.bright_blue,
        bright_magenta = colors.bright_magenta,
        bright_cyan = colors.bright_cyan,
        bright_white = colors.bright_white,
        menu = colors.menu,
        visual = colors.visual,
        gutter_fg = colors.gutter_fg,
        nontext = colors.nontext,
        white = colors.white,
        black = colors.black,
      },
      -- show the '~' characters after the end of buffers
      show_end_of_buffer = false, -- default false
      -- use transparent background
      transparent_bg = true, -- default false
      -- set custom lualine background color
      lualine_bg_color = '#44475a', -- default nil
      -- set italic comment
      italic_comment = true, -- default false
      -- overrides the default highlights with table see `:h synIDattr`
      overrides = {
        TelescopeMatching = { fg = colors.pink },
        TelescopeSelection = { fg = colors.purple, bg = colors.selection, bold = true },
        TelescopePromptPrefix = { bg = colors.bg },
        TelescopePromptNormal = { bg = colors.bg },
        TelescopeResultsNormal = { bg = colors.bg },
        TelescopePreviewNormal = { bg = colors.bg },
        TelescopePromptBorder = { bg = colors.bg, fg = colors.gutter_fg },
        TelescopeResultsBorder = { bg = colors.bg, fg = colors.gutter_fg },
        TelescopePreviewBorder = { bg = colors.bg, fg = colors.gutter_fg },
        TelescopePromptTitle = { fg = colors.green },
        TelescopeResultsTitle = { fg = colors.green },
        TelescopePreviewTitle = { fg = colors.green },
        -- FloatBorder = { bg = colors.bg, fg = colors.grey23 },
        CursorLine = { bg = colors.nontext, bold = false },
        CursorLineNr = { bg = colors.nontext, fg = colors.green, bold = true },
        CursorLineSign = { bg = colors.nontext },
        LineNr = { fg = colors.gutter_fg, bg = colors.black },
        SignColumn = { bg = colors.black },
        -- Directory = { fg = colors.emerald, bold = true },
        -- NormalFloat = { bg = colors.bg },
      },
      -- You can use overrides as table like this
      -- overrides = {
      --   NonText = { fg = "white" }, -- set NonText fg to white
      --   NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
      --   Nothing = {} -- clear highlight of Nothing
      -- },
      -- Or you can also use it like a function to get color from theme
      -- overrides = function (colors)
      --   return {
      --     NonText = { fg = colors.white }, -- set NonText fg to white of theme
      --   }
      -- end,
    }

    vim.cmd [[colorscheme dracula]]
  end,
}
