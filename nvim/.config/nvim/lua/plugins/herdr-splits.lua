-- Ctrl+h/j/k/l move between Neovim splits and herdr panes as one layout.
-- herdr catches the key first (see ~/dotfiles/herdr/.config/herdr/config.toml):
-- when this pane runs Neovim it forwards the key here, and at Neovim's edge
-- the plugin hands focus back to herdr.
--
-- Resizing works the same way. herdr binds Ctrl+Alt+Shift+h/j/k/l (Hyprland
-- owns Alt+h/j/k/l) and forwards Alt+h/j/k/l to Neovim, which resizes its own
-- split or hands the resize to herdr when the window fills the pane.
--
-- Only loads inside herdr. Outside it LazyVim's own Ctrl+h/j/k/l window keys apply.
local modes = { "n", "x", "i" }

local function call(fn)
  return function()
    require("herdr-splits")[fn]()
  end
end

return {
  {
    "lmilojevicc/herdr-splits.nvim",
    cond = vim.env.HERDR_ENV == "1",
    event = "VeryLazy",
    -- Keep the herdr-side scripts on the same commit as this plugin.
    build = ':lua require("herdr-splits").sync_herdr()',
    opts = {
      auto_sync_herdr = true,
      -- Stop at the outer edge instead of wrapping around to the far side.
      at_edge = "stop",
      nav_at_edge = "stop",
    },
    keys = {
      { "<C-h>", call("move_cursor_left"), mode = modes, desc = "Focus split left" },
      { "<C-j>", call("move_cursor_down"), mode = modes, desc = "Focus split down" },
      { "<C-k>", call("move_cursor_up"), mode = modes, desc = "Focus split up" },
      { "<C-l>", call("move_cursor_right"), mode = modes, desc = "Focus split right" },
      { "<M-h>", call("resize_left"), mode = modes, desc = "Move split border left" },
      { "<M-j>", call("resize_down"), mode = modes, desc = "Move split border down" },
      { "<M-k>", call("resize_up"), mode = modes, desc = "Move split border up" },
      { "<M-l>", call("resize_right"), mode = modes, desc = "Move split border right" },
    },
  },
}
