return {
  'rose-pine/neovim',
  name = 'rose-pine',
  config = function()
    require('rose-pine').setup {
      variant = 'auto', -- auto, main, moon, or dawn
      dark_variant = 'main', -- main, moon, or dawn
      dim_inactive_windows = false,
      extend_background_behind_borders = true,

      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
      },

      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },

      palette = {
        -- Override the builtin palette per variant
        main = {
          base = '#000000',
          overlay = '#000000',
          surface = '#000000',
        },
      },

      groups = {
        border = 'muted',
        link = 'iris',
        panel = 'surface',
        error = 'love',
        hint = 'iris',
        info = 'foam',
        note = 'pine',
        todo = 'rose',
        warn = 'gold',

        git_add = 'foam',
        git_change = 'rose',
        git_delete = 'love',
        git_dirty = 'rose',
        git_ignore = 'muted',
        git_merge = 'iris',
        git_rename = 'pine',
        git_stage = 'iris',
        git_text = 'rose',
        git_untracked = 'subtle',

        h1 = 'iris',
        h2 = 'foam',
        h3 = 'rose',
        h4 = 'gold',
        h5 = 'pine',
        h6 = 'foam',
      },

      -- NOTE: Highlight groups are extended (merged) by default. Disable this
      -- per group via `inherit = false`
      highlight_groups = {
        TelescopeMatching = { fg = 'love' },
        TelescopeSelection = { fg = 'iris', bg = 'surface', bold = true },
        TelescopePromptPrefix = { bg = 'base' },
        TelescopePromptNormal = { bg = 'base' },
        TelescopeResultsNormal = { bg = 'base' },
        TelescopePreviewNormal = { bg = 'base' },
        TelescopePromptBorder = { bg = 'base', fg = 'pine' },
        TelescopeResultsBorder = { bg = 'base', fg = 'pine' },
        TelescopePreviewBorder = { bg = 'base', fg = 'pine' },
        TelescopePromptTitle = { bg = 'base', fg = 'iris' },
        TelescopeResultsTitle = { fg = 'iris' },
        TelescopePreviewTitle = { bg = 'base', fg = 'iris' },

        GitSignsAdd = { fg = 'foam', bg = 'base', bold = true },
        GitSignsChange = { fg = 'iris', bg = 'base', bold = true },
        GitSignsDelete = { fg = 'love', bg = 'base', bold = true },
        GitSignsTopDelete = { fg = 'love', bg = 'base', bold = true },
        GitSignsChangeDelete = { fg = 'gold', bg = 'base', bold = true },
        GitSignsUntracked = { fg = 'foam', bg = 'base', bold = true },
        GitSignsCurrentLineBlame = { fg = 'rose', bg = 'base', bold = true },

        FloatBorder = { bg = 'base', fg = 'foam', inherit = false },
        CursorLineNr = { bg = 'surface', fg = 'pine', bold = true },
        CursorLine = { bg = 'pine', bold = false },
        LineNr = { fg = 'foam', bg = 'base' },
        SignColumn = { fg = 'surface', bg = 'base' },
        Directory = { fg = 'foam', bold = true },
        NormalFloat = { bg = '#000000', inherit = false },

        Normal = { bg = '#000000', inherit = true },

        before_highlight = function(group, highlight, palette)
          -- Disable all undercurls
          -- if highlight.undercurl then
          --     highlight.undercurl = false
          -- end
          --
          -- Change palette colour
          -- if highlight.fg == palette.pine then
          --     highlight.fg = palette.foam
          -- end
        end,
      },

      vim.cmd [[colorscheme rose-pine-main]],
      -- vim.cmd("colorscheme rose-pine-moon")
      -- vim.cmd("colorscheme rose-pine-dawn")
    }
  end,
}
