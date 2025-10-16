return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        go = true,
        rust = true,
        typescript = true,
        javascript = true,
        text = true,
        ['*'] = false,
      },
    }
  end,
}
