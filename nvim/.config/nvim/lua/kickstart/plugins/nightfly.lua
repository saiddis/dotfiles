return {
  'bluz71/vim-nightfly-colors',
  name = 'nightfly',
  lazy = false,
  priority = 1000,

  config = function()
    vim.g.nightflyCursorColor = true
    vim.g.nightflyItalics = true
    vim.g.nightflyNormalFloat = true
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'single',
    })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, {
      border = 'single',
    })
    vim.diagnostic.config { float = { border = 'single' } }
    vim.g.nightflyTransparent = false
    vim.g.nightflyUndercurls = true
    vim.g.nightflyUnderlineMatchParen = true
    vim.g.nightflyVirtualTextColor = true
    vim.g.nightflyWinSeparator = 2

    vim.cmd [[colorscheme nightfly]]
  end,
}
