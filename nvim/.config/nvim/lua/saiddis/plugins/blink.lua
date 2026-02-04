return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'brenoprata10/nvim-highlight-colors',
    {
      'supermaven-inc/supermaven-nvim',
      opts = {
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
      },
    },
    {
      'huijiro/blink-cmp-supermaven',
    },
  },
  version = '1.*',
  opts = {
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
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        supermaven = {
          name = 'supermaven',
          module = 'blink-cmp-supermaven',
          async = true,
        },
      },
    },
  },
}
