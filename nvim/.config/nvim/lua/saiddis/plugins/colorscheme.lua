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

    colors.bg = '#000000'
    colors.white = '#D7D7D7'
    colors.green = '#B1E268'
    colors.lime = '#25FF5F'
    colors.emerald = '#5ADA7C'
    colors.turquoise = '#7fdbca'
    colors.khaki = '#E3CF65'
    colors.yellow = '#E6E666'
    colors.orange = '#FC9949'
    colors.blue = '#8DBBD3'
    colors.sky = '#5CCEFF'
    colors.purple = '#AE81FF'
    colors.violet = '#E593EE'
    colors.lavender = '#a9b1d6'

    require('moonfly').custom_colors(colors)

    vim.cmd [[colorscheme moonfly]]

    local OverrideColors = {
      SnacksPickerMatch = { fg = colors.coral },
      SnacksPickerSelected = { fg = colors.purple, bg = colors.grey7, bold = true },
      SnacksPickerPreviewCursorLine = { bg = colors.grey15 },
      SnacksPickerPrompt = { bg = colors.grey7, fg = colors.emerald },
      SnacksPickerInput = { bg = colors.grey7 },
      SnacksPickerInputBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerInputTitle = { bg = colors.mineral, fg = colors.emerald },
      SnacksPickerList = { bg = colors.grey7 },
      SnacksPickerListBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerListTitle = { bg = colors.mineral, fg = colors.emerald },
      SnacksPickerListCursorLine = { bg = colors.grey15 },
      SnacksPickerPreview = { bg = colors.bg },
      SnacksPickerPreviewBorder = { bg = colors.black, fg = colors.black },
      SnacksPickerPreviewTitle = { bg = colors.mineral, fg = colors.emerald },
      SnacksPickerBoxBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksWinSeparator = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerGitStatusModified = { fg = colors.orange },
      SnacksPickerGitStatusChanged = { fg = colors.yellow },
      SnacksPickerTree = { fg = colors.grey15, bold = false },
      SnacksIndentScope = { fg = colors.grey15 },

      FloatBorder = { bg = colors.grey7, fg = colors.grey7 },
      FloatTitle = { fg = colors.emerald, bg = colors.mineral },
      NormalFloat = { bg = colors.grey7 },
      CursorLineNr = { bg = colors.bg, fg = colors.emerald, bold = true },
      CursorLine = { bg = colors.grey7, bold = false },
      CursorLineSign = { bg = colors.grey15 },
      SignColumn = { fg = colors.mineral, bg = colors.grey7 },
    }

    for hl, col in pairs(OverrideColors) do
      vim.api.nvim_set_hl(0, hl, col)
    end
  end,
}
