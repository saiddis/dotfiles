-- bento.nvim from the old config (~/dotfiles/legacy/nvim, bento.lua), same keys.
-- Ctrl + ; opens the buffer menu (and, pressed again, jumps to the last
-- buffer); in it a buffer's label opens it, Backspace then a label deletes,
-- | and _ open in a vertical / horizontal split, * locks, Esc closes,
-- [ and ] page. At most 5 buffers stay open; the least used one goes.
-- bento v2 registers nothing itself: the old v1 options map to API calls.
return {
  {
    "serhez/bento.nvim",
    event = "VeryLazy",
    config = function()
      require("bento").setup({
        max_open_buffers = 5,
        map_last_accessed = false,
        -- No notice for each buffer the 5-buffer cap closes (the tab bar
        -- already shows what is open)
        buffer_notify_on_delete = false,
        -- A thin rounded grey line (BentoBorder, Moonfly theme) on the same
        -- black (no grey panel: every window stays black), so the menu
        -- reads apart from the code under it
        ui = {
          floating = {
            border = vim.tbl_map(function(c)
              return { c, "BentoBorder" }
            end, { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }),
          },
        },
      })

      local api = require("bento.api")
      api.register_expand_key("<C-;>")
      api.register_last_buffer_key("<C-;>")
      api.register_collapse_key("<Esc>")
      api.register_prev_page_key("[")
      api.register_next_page_key("]")

      api.register_action("open", { key = "<CR>", action = api.actions.open, hl = "DiagnosticVirtualTextHint" })
      api.register_action("delete", { key = "<BS>", action = api.actions.delete, hl = "DiagnosticVirtualTextError" })
      api.register_action("vsplit", { key = "|", action = api.actions.vsplit, hl = "DiagnosticVirtualTextInfo" })
      api.register_action("split", { key = "_", action = api.actions.split, hl = "DiagnosticVirtualTextInfo" })
      api.register_action("lock", { key = "*", action = api.actions.lock, hl = "DiagnosticVirtualTextWarn" })
      api.set_default_action("open")
    end,
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<C-;>", desc = "Buffer menu (bento)" } } },
  },
  {
    -- The label colour already shows the mode (red after Backspace), so
    -- bento's "Action mode: delete" notice is dropped
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      table.insert(opts.routes, { filter = { event = "notify", find = "^Action mode:" }, opts = { skip = true } })
    end,
  },
}
