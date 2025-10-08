return {
  'zbirenbaum/copilot.lua',
  dependancies = {
    'copilotlsp-nvim/copilot-lsp',
  },
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      panel = {
        enabled = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        keymap = {
          accept = '<C-l>',
          accept_word = false,
          accept_line = false,
          prev = '<C-p>',
          next = '<C-n>',
          dismiss = '<C-e>',
        },
      },
      filetypes = {
        go = true,
        typescript = true,
        javascript = true,
        text = true,
        ['*'] = false,
      },
    }
    -- Define suggestion accept function
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuOpen',
      callback = function()
        vim.b.copilot_suggestion_hidden = true
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuClose',
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })
  end,
}
