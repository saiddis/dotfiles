return {
  'bluz71/vim-moonfly-colors',
  name = 'moonfly',
  lazy = false,
  priority = 1000,

  config = function()
    vim.g.moonflyNormalFloat = true
    vim.diagnostic.config { float = { border = 'single' } }
    vim.g.moonflyTransparent = true
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

    local custom_highlight = vim.api.nvim_create_augroup('CustomHighlight', {})
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'moonfly',
      callback = function()
        -- vim.api.nvim_set_hl(0, 'Normal', { bg = '#000000' })
      end,
      group = custom_highlight,
    })

    local black = '#000000'

    -- vim.cmd()

    vim.cmd [[colorscheme moonfly]]
    local colors = require('moonfly').palette
    local TelescopeColor = {
      TelescopeMatching = { fg = colors.coral },
      TelescopeSelection = { fg = colors.purple, bg = colors.grey7, bold = true },
      TelescopePromptPrefix = { bg = black },
      TelescopePromptNormal = { bg = black },
      TelescopeResultsNormal = { bg = black },
      TelescopePreviewNormal = { bg = black },
      TelescopePromptBorder = { bg = black, fg = colors.emerald },
      TelescopeResultsBorder = { bg = black, fg = colors.emerald },
      TelescopePreviewBorder = { bg = black, fg = colors.emerald },
      TelescopePromptTitle = { bg = black, fg = colors.purple },
      TelescopeResultsTitle = { fg = colors.purple },
      TelescopePreviewTitle = { bg = black, fg = colors.purple },
      FloatBorder = { bg = black, fg = colors.emerald },
      CursorLineNr = { bg = colors.grey7, fg = colors.emerald, bold = true },
      CursorLine = { bg = colors.grey7, bold = false },
      LineNr = { fg = colors.mineral, bg = colors.black },
      SignColumn = { fg = colors.mineral, bg = colors.black },
      GitSignsAdd = { fg = colors.lime, bg = colors.black, bold = true },
      GitSignsChange = { fg = colors.violet, bg = colors.black, bold = true },
      GitSignsDelete = { fg = colors.crimson, bg = colors.black, bold = true },
      GitSignsTopDelete = { fg = colors.crimson, bg = colors.black, bold = true },
      GitSignsChangeDelete = { fg = colors.orange, bg = colors.black, bold = true },
      GitSignsUntracked = { fg = colors.turquoise, bg = colors.black, bold = true },
      GitSignsCurrentLineBlame = { fg = colors.crimson, bg = colors.black, bold = true },
      Directory = { fg = colors.green, bold = true },
      NormalFloat = { bg = black },
    }

    for hl, col in pairs(TelescopeColor) do
      vim.api.nvim_set_hl(0, hl, col)
    end
  end,
}
