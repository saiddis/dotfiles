return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    enabled = true,
  },
  config = function()
    local status_ok, indent_blankline = pcall(require, 'ibl')
    if not status_ok then
      return
    end
    -- vim.opt.list = true
    -- vim.opt.listchars:append 'space:⋅'
    -- vim.opt.listchars:append 'eol:¶'
    -- vim.opt.listchars:append 'tab:|⇢'
    -- vim.opt.listchars:append 'trail:·'
    -- vim.opt.listchars:append 'extends:>'
    -- vim.opt.listchars:append 'precedes:<'

    indent_blankline.setup {
      indent = {
        char = '',
        highlight = 'LineNr',
      },
      whitespace = {
        highlight = 'LineNr',
        remove_blankline_trail = false,
      },
      scope = {
        char = '▏',
        show_start = false,
        highlight = 'LineNr',
      },
      exclude = {
        filetypes = {
          'FTerm',
          'alpha',
          'packer',
          'NvimTree',
          'conf',
          'alpha',
        },
      },
    }
  end,
}
