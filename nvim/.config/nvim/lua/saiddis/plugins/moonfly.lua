return {
  'bluz71/vim-moonfly-colors',
  name = 'moonfly',
  lazy = false,
  priority = 1000,

  config = function()
    vim.g.moonflyNormalFloat = false
    vim.diagnostic.config { float = { border = 'single' } }
    vim.g.moonflyTransparent = false
    vim.g.moonflyUndercurls = true
    vim.g.moonflyWinSeparator = 0
    vim.g.moonflyUnderlineMatchParen = true
    vim.g.moonflyItalics = true
    vim.g.nightflyCursorColor = true

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'single',
    })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, {
      border = 'single',
    })

    local colors = require('moonfly').palette

    -- colors.purple = '#CD6BE6'
    -- colors.violet = '#E173FC'
    -- colors.cranberry = '#FF7E7E'
    -- colors.red = '#F45B5D'
    -- colors.lavender = '#C9C9F5'
    --
    -- colors.bg = '#000000'
    -- colors.black = '#0D1B20'
    -- colors.white = '#E4E5EC'
    -- colors.grey15 = '#1E2A2E'
    -- colors.green = '#6FDB59'
    -- colors.lime = '#79EA97'
    -- colors.emerald = '#69FF94'
    -- colors.turquoise = '#43DBD2'
    -- colors.khaki = '#FFD64C'
    -- colors.yellow = '#FFFA9E'
    -- colors.orange = '#FFB86C'
    -- colors.sky = '#48C8ED'
    -- colors.blue = '#4CB5FF'
    -- colors.coral = '#DF8585'
    --

    colors.purple = '#AE81FF'
    colors.violet = '#E593EE'
    colors.cranberry = '#ff5874'
    colors.red = '#fc514e'
    colors.lavender = '#B9B9FA'
    colors.orchid = '#F77AB8'

    colors.bg = '#000000'
    colors.black = '#0C1518'
    colors.white = '#d6deeb'
    colors.grey15 = '#1B2327'
    colors.green = '#B1E268'
    colors.lime = '#25FF5F'
    colors.emerald = '#5ADA7C'
    colors.turquoise = '#7fdbca'
    colors.khaki = '#E6E666'
    colors.yellow = '#FDFD70'
    colors.orange = '#FC9949'
    colors.sky = '#70BDF5'
    colors.blue = '#339CFF'
    colors.coral = '#FC9B7D'

    require('moonfly').custom_colors(colors)

    vim.cmd [[colorscheme moonfly]]

    local OverrideColors = {
      TelescopeMatching = { fg = colors.coral },
      TelescopeSelection = { fg = colors.purple, bg = colors.grey15, bold = true },
      TelescopePromptPrefix = { bg = colors.black },
      TelescopePromptNormal = { bg = colors.grey15 },
      TelescopeResultsNormal = { bg = colors.black },
      TelescopePreviewNormal = { bg = colors.black },
      TelescopePromptBorder = { bg = colors.grey15, fg = colors.grey15 },
      TelescopeResultsBorder = { bg = colors.black, fg = colors.black },
      TelescopePreviewBorder = { bg = colors.black, fg = colors.black },
      TelescopePromptTitle = { bg = colors.mineral, fg = colors.emerald },
      TelescopeResultsTitle = { bg = colors.mineral, fg = colors.emerald },
      TelescopePreviewTitle = { bg = colors.mineral, fg = colors.emerald },

      GitSignsAdd = { fg = colors.lime, bg = colors.black, bold = true },
      GitSignsChange = { fg = colors.violet, bg = colors.black, bold = true },
      GitSignsDelete = { fg = colors.crimson, bg = colors.black, bold = true },
      GitSignsTopDelete = { fg = colors.crimson, bg = colors.black, bold = true },
      GitSignsChangeDelete = { fg = colors.orange, bg = colors.black, bold = true },
      GitSignsUntracked = { fg = colors.turquoise, bg = colors.black, bold = true },
      GitSignsCurrentLineBlame = { fg = colors.crimson, bg = colors.black, bold = true },

      FloatBorder = { bg = colors.black, fg = colors.black },
      NormalFloat = { bg = colors.black },
      CursorLineNr = { bg = colors.grey15, fg = colors.emerald, bold = true },
      CursorLine = { bg = colors.grey15, bold = false },
      CursorLineSign = { bg = colors.grey15 },
      LineNr = { fg = colors.mineral, bg = colors.black },
      SignColumn = { fg = colors.mineral, bg = colors.black },
      Directory = { fg = colors.emerald, bold = true },

      -- String = { fg = colors.yellow },
    }

    for hl, col in pairs(OverrideColors) do
      vim.api.nvim_set_hl(0, hl, col)
    end
  end,
}
