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

    -- colors.bg = '#000000'
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
    colors.coral = '#E0828D'
    colors.purple = '#AE81FF'
    colors.violet = '#E593EE'
    colors.cranberry = '#FB7DA7'
    colors.red = '#D95555'
    colors.crimson = '#E593EE'
    colors.lavender = '#a9b1d6'
    colors.orchid = '#BDA9D4'

    require('moonfly').custom_colors(colors)

    vim.cmd [[colorscheme moonfly]]

    local OverrideColors = {
      SnacksPickerMatch = { fg = colors.coral },
      SnacksPickerSelected = { fg = colors.purple, bg = colors.grey15, bold = true },
      SnacksPickerListCursorLine = { bg = colors.grey15 },
      SnacksPickerPreviewCursorLine = { bg = colors.grey15 },
      SnacksPickerPrompt = { bg = colors.bg, fg = colors.emerald },
      SnacksPickerInput = { bg = colors.bg },
      SnacksPickerInputBorder = { bg = colors.bg, fg = colors.emerald },
      SnacksPickerInputTitle = { bg = colors.mineral, fg = colors.emerald },
      SnacksPickerList = { bg = colors.grey7 },
      SnacksPickerListTitle = { bg = colors.mineral, fg = colors.emerald },
      SnacksPickerPreview = { bg = colors.bg },
      SnacksPickerPreviewBorder = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerPreviewTitle = { bg = colors.mineral, fg = colors.emerald },
      SnacksPickerBoxBorder = { bg = colors.bg, fg = colors.emerald },
      SnacksWinSeparator = { bg = colors.grey7, fg = colors.grey7 },
      SnacksPickerGitStatusModified = { fg = colors.orchid },
      SnacksPickerGitStatusChanged = { fg = colors.orange },

      GitSignsAdd = { fg = colors.emerald, bg = colors.bg, bold = true },
      GitSignsChange = { fg = colors.violet, bg = colors.bg, bold = true },
      GitSignsDelete = { fg = colors.crimson, bg = colors.bg, bold = true },
      GitSignsTopDelete = { fg = colors.crimson, bg = colors.bg, bold = true },
      GitSignsChangeDelete = { fg = colors.orange, bg = colors.bg, bold = true },
      GitSignsUntracked = { fg = colors.turquoise, bg = colors.bg, bold = true },
      GitSignsCurrentLineBlame = { fg = colors.crimson, bg = colors.bg, bold = true },

      FloatBorder = { bg = colors.grey7, fg = colors.grey7 },
      FloatTitle = { fg = colors.emerald, bg = colors.mineral },
      NormalFloat = { bg = colors.grey7 },
      CursorLineNr = { bg = colors.bg, fg = colors.emerald, bold = true },
      CursorLine = { bg = colors.grey15, bold = false },
      CursorLineSign = { bg = colors.grey15 },
      -- LineNr = { fg = colors.mineral, bg = colors.grey7 },
      SignColumn = { fg = colors.mineral, bg = colors.grey7 },
      ['@keyword.import'] = { fg = colors.red },
    }

    for hl, col in pairs(OverrideColors) do
      vim.api.nvim_set_hl(0, hl, col)
    end
  end,
}
-- return {
--
--   'Yazeed1s/oh-lucy.nvim',
--   lazy = false,
--   priority = 1000,
--   config = function()
--     local colors = require 'oh-lucy.colors'
--     colors.bg = '#000000'
--     colors.pink
--     vim.cmd [[colorscheme oh-lucy]]
--
--     local OverrideColors = {
--
--       SnacksPickerPrompt = { bg = colors.bg },
--       SnacksPickerInput = { bg = colors.bg },
--       SnacksPickerList = { bg = colors.black },
--       SnacksPickerTree = { bg = colors.black, fg = colors.non_text },
--       SnacksWinSeparator = { fg = colors.bg },
--       SnacksPickerPreview = { bg = colors.bg },
--     }
--
--     for hl, col in pairs(OverrideColors) do
--       vim.api.nvim_set_hl(0, hl, col)
--     end
--   end,
-- }
