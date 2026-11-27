-- Current-window indicator from the old config (~/dotfiles/legacy/nvim): the borders
-- around the window you are in light up in moonfly blue. The colour is set
-- by the Moonfly theme (ColorfulWinSep in its neovim.lua).
return {
  "nvim-zh/colorful-winsep.nvim",
  -- VeryLazy as well: windows opened at startup (`nvim -O a b`) exist
  -- before any WinNew fires
  event = { "WinNew", "VeryLazy" },
  opts = {
    animate = { enabled = false },
  },
  config = function(_, opts)
    require("colorful-winsep").setup(opts)
    -- Draw for the windows that are already open, through the plugin's own
    -- autocommand group only
    vim.schedule(function()
      vim.api.nvim_exec_autocmds("WinEnter", { group = "colorful_winsep" })
    end)

    -- Only the Neovim that has focus shows blue: when its herdr pane or
    -- Ghostty window loses focus (herdr and Ghostty both send focus events),
    -- the indicator takes the plain separator colour until focus comes back,
    -- so the blue frame of the focused herdr pane is the only blue marker.
    local group = vim.api.nvim_create_augroup("colorful_winsep_focus", { clear = true })
    local saved
    local function dim()
      saved = vim.api.nvim_get_hl(0, { name = "ColorfulWinSep" })
      vim.api.nvim_set_hl(0, "ColorfulWinSep", { link = "WinSeparator" })
    end
    vim.api.nvim_create_autocmd("FocusLost", {
      group = group,
      callback = function()
        if not saved then
          dim()
        end
      end,
    })
    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        if saved then
          vim.api.nvim_set_hl(0, "ColorfulWinSep", saved)
          saved = nil
        end
      end,
    })
    -- A theme reload while unfocused brings the blue back; keep it dimmed
    -- and remember the new colour for when focus returns.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        if saved then
          -- after the theme's own deferred overrides (30 ms)
          vim.defer_fn(dim, 100)
        end
      end,
    })
  end,
}
