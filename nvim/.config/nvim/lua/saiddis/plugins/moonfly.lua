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
    colors.red = '#ff5874'
    colors.lavender = '#a9b1d6'
    colors.orchid = '#F77AB8'

    colors.bg = '#000000'
    colors.white = '#E7EAEE'
    -- colors.grey15 = colors.grey8
    -- colors.grey7 = '#121212'
    -- colors.black = '#000000'
    colors.green = '#B1E268'
    colors.lime = '#25FF5F'
    colors.emerald = '#5ADA7C'
    colors.turquoise = '#7fdbca'
    colors.khaki = '#E6E666'
    colors.yellow = '#FDFD70'
    colors.orange = '#FC9949'
    colors.blue = '#AFDBFD'
    colors.sky = '#5CCEFF'
    colors.coral = '#FC9B7D'

    require('moonfly').custom_colors(colors)

    vim.cmd [[colorscheme moonfly]]

    local OverrideColors = {
      -- TelescopeMatching = { fg = colors.coral },
      -- TelescopeSelection = { fg = colors.purple, bg = colors.grey7 },
      -- TelescopePromptPrefix = { bg = colors.black },
      -- TelescopePromptNormal = { bg = colors.black },
      -- TelescopePromptBorder = { bg = colors.black, fg = colors.black },
      -- TelescopeResultsNormal = { bg = colors.black },
      -- TelescopePreviewNormal = { bg = colors.black },
      -- TelescopeResultsBorder = { bg = colors.black, fg = colors.black },
      -- TelescopePreviewBorder = { bg = colors.black, fg = colors.black },
      -- TelescopePromptTitle = { bg = colors.mineral, fg = colors.emerald },
      -- TelescopeResultsTitle = { bg = colors.mineral, fg = colors.emerald },
      -- TelescopePreviewTitle = { bg = colors.mineral, fg = colors.emerald },
      --
      -- Matching and Selection
      SnacksPickerMatch = { fg = colors.coral },
      SnacksPickerSelected = { fg = colors.purple, bg = colors.grey15, bold = true },
      SnacksPickerListCursorLine = { bg = colors.grey15 },
      SnacksPickerPreviewCursorLine = { bg = colors.grey15 },
      -- Prompt highlights
      SnacksPickerInput = { bg = colors.grey7 },
      SnacksPickerPrompt = { bg = colors.grey7, fg = colors.emerald },
      SnacksPickerInputBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerInputTitle = { bg = colors.mineral, fg = colors.emerald },
      -- Results highlights
      SnacksPickerList = { bg = colors.grey7 },
      SnacksPickerListBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerListTitle = { bg = colors.mineral, fg = colors.emerald },
      -- Preview highlights
      SnacksPickerPreview = { bg = colors.grey7 },
      SnacksPickerPreviewBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerPreviewTitle = { bg = colors.mineral, fg = colors.emerald },

      SnacksPickerBoxBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksWinSeparator = { bg = colors.grey7, fg = colors.grey7 },

      SnacksPickerGitStatusModified = { fg = colors.orchid },
      SnacksPickerGitStatusChanged = { fg = colors.orange },

      GitSignsAdd = { fg = colors.emerald, bg = colors.black, bold = true },
      GitSignsChange = { fg = colors.violet, bg = colors.black, bold = true },
      GitSignsDelete = { fg = colors.crimson, bg = colors.black, bold = true },
      GitSignsTopDelete = { fg = colors.crimson, bg = colors.black, bold = true },
      GitSignsChangeDelete = { fg = colors.orange, bg = colors.black, bold = true },
      GitSignsUntracked = { fg = colors.turquoise, bg = colors.black, bold = true },
      GitSignsCurrentLineBlame = { fg = colors.crimson, bg = colors.black, bold = true },

      FloatBorder = { bg = colors.grey7, fg = colors.grey7 },
      FloatTitle = { fg = colors.emerald, bg = colors.mineral },
      NormalFloat = { bg = colors.grey7 },
      CursorLineNr = { bg = colors.grey15, fg = colors.emerald, bold = true },
      CursorLine = { bg = colors.grey15, bold = false },
      CursorLineSign = { bg = colors.grey15 },
      LineNr = { fg = colors.mineral, bg = colors.grey7 },
      SignColumn = { fg = colors.mineral, bg = colors.grey7 },
      Boolean = { fg = colors.green },
      Parameter = { fg = colors.orange },
      ['@keyword.return'] = { fg = colors.cranberry },
    }

    for hl, col in pairs(OverrideColors) do
      vim.api.nvim_set_hl(0, hl, col)
    end
  end,
}
