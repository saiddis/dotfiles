return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'brenoprata10/nvim-highlight-colors',
    'zbirenbaum/copilot.lua',
    'fang2hou/blink-copilot',
  },

  version = '1.*',

  opts = {
    -- keymap = { preset = 'super-tab' },

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      documentation = { auto_show = true },
      menu = {
        draw = {
          components = {
            -- customize the drawing of kind icons
            kind_icon = {
              text = function(ctx)
                -- default kind icon
                local icon = ctx.kind_icon
                -- if LSP source, check for color derived from documentation
                if ctx.item.source_name == 'LSP' then
                  local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                  if color_item and color_item.abbr ~= '' then
                    icon = color_item.abbr
                  end
                end
                return icon .. ctx.icon_gap
              end,
              highlight = function(ctx)
                -- default highlight group
                local highlight = 'BlinkCmpKind' .. ctx.kind
                -- if LSP source, check for color derived from documentation
                if ctx.item.source_name == 'LSP' then
                  local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                  if color_item and color_item.abbr_hl_group then
                    highlight = color_item.abbr_hl_group
                  end
                end
                return highlight
              end,
            },
          },
        },
      },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },

    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },

  -- config = function()
  --   vim.api.nvim_create_autocmd('LspAttach', {
  --     group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  --     callback = function(event)
  --       local map = function(keys, func, desc, mode)
  --         mode = mode or 'n'
  --         vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  --       end
  --
  --       map('gn', vim.lsp.buf.rename, '[R]e[n]ame')
  --       map('ga', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
  --       map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  --       map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  --       map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  --       map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  --       map('go', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
  --       map('gs', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
  --       map('gt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
  --
  --       -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
  --       ---@param client vim.lsp.Client
  --       ---@param method vim.lsp.protocol.Method
  --       ---@param bufnr? integer some lsp support methods only in specific files
  --       ---@return boolean
  --       local function client_supports_method(client, method, bufnr)
  --         if vim.fn.has 'nvim-0.11' == 1 then
  --           return client:supports_method(method, bufnr)
  --         else
  --           return client.supports_method(method, { bufnr = bufnr })
  --         end
  --       end
  --
  --       local client = vim.lsp.get_client_by_id(event.data.client_id)
  --       if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
  --         local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
  --         vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  --           buffer = event.buf,
  --           group = highlight_augroup,
  --           callback = vim.lsp.buf.document_highlight,
  --         })
  --
  --         vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  --           buffer = event.buf,
  --           group = highlight_augroup,
  --           callback = vim.lsp.buf.clear_references,
  --         })
  --
  --         vim.api.nvim_create_autocmd('LspDetach', {
  --           group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
  --           callback = function(event2)
  --             vim.lsp.buf.clear_references()
  --             vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
  --           end,
  --         })
  --       end
  --
  --       if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
  --         map('<leader>th', function()
  --           vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
  --         end, '[T]oggle Inlay [H]ints')
  --       end
  --     end,
  --   })
  -- end,
}
