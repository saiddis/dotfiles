-- diagnostics.lua (or whatever file you source from your init)

local M = {}

-- Create a custom namespace for filtered signs
local ns = vim.api.nvim_create_namespace 'my_filtered_diagnostics'

-- Keep the original signs handler
local orig_signs = vim.diagnostic.handlers.signs

-- Override signs handler: only show the most severe diagnostic per line
vim.diagnostic.handlers.signs = {
  show = function(_, bufnr, _, opts)
    local diagnostics = vim.diagnostic.get(bufnr)

    local max_per_line = {}
    for _, d in ipairs(diagnostics) do
      local m = max_per_line[d.lnum]
      if not m or d.severity < m.severity then
        max_per_line[d.lnum] = d
      end
    end

    local filtered = vim.tbl_values(max_per_line)
    orig_signs.show(ns, bufnr, filtered, opts)
  end,
  hide = function(_, bufnr)
    orig_signs.hide(ns, bufnr)
  end,
}

-- Define nice icons for diagnostic signs
local signs = {
  Error = ' ',
  Warn = ' ',
  Hint = '󰌵 ',
  Info = ' ',
}
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

-- Default diagnostic settings
vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    spacing = 2,
  },
  signs = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

-- =========== Custom CLI Diagnostics ===========

-- Example: set diagnostics from an external tool (inspired by the article)
-- Suppose you have a tool `mytool` that when run prints something like:
-- ```
-- 13:3
-- Something wrong here
-- ```
-- (first line is "line:col", second line is the message)

function M.run_mytool_on_buffer()
  -- Reset diagnostics in our custom namespace
  vim.diagnostic.reset(ns, 0) -- 0 means current buffer

  local fname = vim.api.nvim_buf_get_name(0)
  if fname == '' then
    return
  end

  local cmd = string.format('mytool -check %s', vim.fn.shellescape(fname))
  local output = vim.fn.systemlist(cmd)
  local exit = vim.v.shell_error

  if exit ~= 0 and #output >= 2 then
    local line, col = string.match(output[1], '(%d+):(%d+)')
    if line and col then
      local msg = output[2]
      vim.diagnostic.set(ns, 0, {
        {
          lnum = tonumber(line) - 1, -- diagnostics are 0-based
          col = tonumber(col) - 1,
          message = msg,
          severity = vim.diagnostic.severity.ERROR,
        },
      })
    end
  end
end

-- Auto run on save or open (you can adjust events)
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('MyToolDiagnostics', { clear = true }),
  pattern = '*', -- or a specific filetype, e.g. "*.go" or "*.api.go"
  callback = function()
    M.run_mytool_on_buffer()
  end,
})

-- =========== LSP Integration (optional) ===========

-- If you use lspconfig, you can wrap or augment the `on_attach` to ensure diagnostics are active.
-- E.g.:
-- local lspconfig = require("lspconfig")
-- lspconfig.tsserver.setup({
--   on_attach = function(client, bufnr)
--     -- (you can put keymaps, etc. here)
--     -- diagnostics are already handled by vim.diagnostic
--   end,
-- })

return M
