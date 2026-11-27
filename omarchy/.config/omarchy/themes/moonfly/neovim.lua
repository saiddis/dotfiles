-- Neovim keeps YOUR modified moonfly (from ~/dotfiles/legacy/nvim,
-- lua/plugins/configs/moonfly.lua): the custom palette below, moonfly's own
-- colour mappings and your original highlight overrides. The rest of Omarchy
-- uses stock moonfly from colors.toml. Plus fixes for Omarchy's
-- transparency.lua (apply() below) and a lighter grey status bar and tab bar.
local custom = {
  bg = "#000000",
  white = "#D7D7D7",
  green = "#B1E268",
  lime = "#25FF5F",
  emerald = "#38DC90",
  turquoise = "#7FDBCA",
  khaki = "#E3CF65",
  yellow = "#E6E666",
  orange = "#FC9949",
  blue = "#5588FF",
  sky = "#5CCEFF",
  purple = "#AE81FF",
  violet = "#E593EE",
  lavender = "#A9B1D6",
}

-- Status bar and tab bar background: moonfly grey11 (#1C1C1C, the theme's
-- float_background), one step above the #121212 window borders
local bar = "#1C1C1C"

return {
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    priority = 1000,
    config = function()
      vim.g.moonflyNormalFloat = false
      vim.g.moonflyTransparent = false
      vim.g.moonflyUndercurls = true
      vim.g.moonflyWinSeparator = 0
      vim.g.moonflyUnderlineMatchParen = true
      vim.g.moonflyItalics = true
      -- Diagnostic messages after the line in their severity colour (errors
      -- red, warnings yellow, info sky, hints turquoise) on a grey11 row,
      -- instead of moonfly's single dim grey for all of them
      vim.g.moonflyVirtualTextColor = true

      -- Your custom palette, passed to moonfly under its own names, so every
      -- highlight keeps moonfly's own colour mappings.
      local moonfly = require("moonfly")
      local colors = moonfly.palette
      for name, value in pairs(custom) do
        colors[name] = value
      end
      moonfly.custom_colors(colors)
      colors = moonfly.palette

      -- Your original highlight overrides
      local ui = {
        bg_primary = colors.bg,
        fg_primary = colors.white,
        bg_secondary = colors.grey7,
        fg_secondary = colors.mineral,
        bg_highlight = colors.mineral,
        fg_highlight = colors.blue,
        bg_border = colors.grey7,
        fg_border = colors.grey7,
        selected = colors.grey15,
      }
      local overrides = {
        NormalFloat = { bg = ui.bg_secondary, fg = ui.fg_primary },
        FloatBorder = { bg = ui.bg_border, fg = ui.fg_border },
        FloatTitle = { bg = ui.bg_highlight, fg = ui.fg_highlight, bold = true },
        SnacksPickerGitStatusModified = { fg = colors.orange },
        SnacksPickerGitStatusChanged = { fg = colors.yellow },
        TroubleIndent = { bg = ui.bg_secondary, fg = ui.fg_secondary },
        TroubleCount = { bg = ui.bg_highlight, fg = ui.fg_highlight, bold = true },
        TroublePos = { bg = ui.bg_secondary, fg = ui.fg_secondary },
        -- Your old config's separator: a full-cell strip in grey7, between the
        -- file tree and the editor and between splits
        WinSeparator = { bg = ui.bg_border, fg = ui.fg_border },
        NeoTreeWinSeparator = { link = "WinSeparator" },
        -- bento's buffer menu (plugins/bento.lua): a thin rounded line in
        -- grey30 on the editor black, so its corners show
        BentoBorder = { fg = colors.grey30, bg = "NONE" },
        -- The diagnostic float (]d in a narrow split, <leader>cd): like
        -- bento's menu, the grey30 line on the editor black (the float's
        -- own panel is black too, keymaps.lua)
        DiagnosticFloatBorder = { fg = colors.grey30, bg = "NONE" },
        -- colorful-winsep (plugins/colorful-winsep.lua): the current window's
        -- borders in blue on the same grey7 strip, as in the old config
        ColorfulWinSep = { bg = ui.bg_secondary, fg = ui.fg_highlight },
        CursorLineNr = { bg = ui.selected, fg = ui.fg_highlight, bold = true },
        CursorLine = { bg = ui.selected, bold = false },
        CursorLineSign = { bg = ui.selected },
        LineNr = { fg = ui.fg_secondary },
        FoldColumn = { fg = ui.fg_secondary },
        CursorLineFold = { bg = ui.selected },
        ColorColumn = { bg = ui.bg_secondary },
        -- Omarchy fixes: Pmenu and the file tree's cursor line lose their
        -- background to transparency.lua
        Pmenu = { bg = ui.bg_secondary, fg = ui.fg_primary },
        NeoTreeCursorLine = { bg = ui.selected },
        -- Inactive splits, file trees and the picker's other panes stay as
        -- see-through as the window you are in
        NormalNC = { bg = "NONE" },
        -- Snacks' explorer sidebar frame defaults to NormalFloat's grey
        SnacksNormal = { link = "Normal" },
        SnacksNormalNC = { link = "NormalNC" },
        -- Status bar and tab bar on a lighter grey
        StatusLine = { bg = bar, fg = ui.fg_primary },
        StatusLineNC = { bg = bar, fg = colors.grey62 },
        TabLine = { bg = bar, fg = colors.grey62 },
        TabLineFill = { bg = bar, fg = colors.grey39 },
        TabLineSel = { fg = colors.blue, bold = true },
        MoonflyBufferLineOffset = { bg = bar, fg = colors.blue },
        -- Diagnostic squiggles in their severity colour, the text keeps its
        -- own (owner's choice). herdr drops underline colours, so inside
        -- herdr the squiggle is drawn in the text's colour; the sign column
        -- and the message after the line still show the severity there.
        DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
        DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow },
        DiagnosticUnderlineInfo = { undercurl = true, sp = colors.sky },
        DiagnosticUnderlineHint = { undercurl = true, sp = colors.turquoise },
        DiagnosticUnderlineOk = { undercurl = true, sp = colors.emerald },
      }

      local black = tonumber(custom.bg:sub(2), 16)

      local function apply()
        if vim.g.colors_name ~= "moonfly" then
          return
        end
        local hl = vim.api.nvim_set_hl
        for name, spec in pairs(vim.api.nvim_get_hl(0, {})) do
          if not spec.link then
            local changed = false
            -- Pure-black backgrounds render as opaque blocks on the
            -- see-through terminal (picker borders, MatchParen, ...).
            if spec.bg == black then
              spec.bg, changed = nil, true
            end
            if changed then
              hl(0, name, spec)
            end
          end
        end
        for name, spec in pairs(overrides) do
          hl(0, name, spec)
        end
      end

      local group = vim.api.nvim_create_augroup("omarchy_moonfly_overrides", { clear = true })
      -- Deferred so it runs after bufferline re-derives its colours and after
      -- Omarchy's transparency.lua (startup, VeryLazy and theme hot-reload).
      local function later()
        vim.defer_fn(apply, 30)
      end
      vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = later })
      vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = later })
      vim.api.nvim_create_autocmd("User", { group = group, pattern = "VeryLazy", callback = later })

    end,
  },
  {
    -- Tab bar on a lighter grey (bufferline re-applies these itself on every
    -- colour scheme change): the current buffer opens onto the see-through
    -- editor and separators blend into the bar.
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      opts.highlights = function(defaults)
        local hls = vim.deepcopy(defaults.highlights)
        if vim.g.colors_name ~= "moonfly" then
          return hls
        end
        for name, hl in pairs(hls) do
          if type(hl) == "table" then
            hl.bg = name:match("selected") and "NONE" or bar
            if name:match("separator") then
              hl.fg = bar
            end
          end
        end
        return hls
      end
      -- The file tree's header in the tab bar ("Neo-tree", and the blank one
      -- over the Snacks explorer) sits on the same grey as the tabs, instead
      -- of LazyVim's see-through Directory highlight
      for _, offset in ipairs(opts.options and opts.options.offsets or {}) do
        offset.highlight = "MoonflyBufferLineOffset"
      end
    end,
  },
  {
    -- Omarchy's lualine-transparent.lua clears the middle sections; this
    -- spec loads after it (plugins.theme > plugins.lualine-transparent) and
    -- puts them on a lighter grey while moonfly is active.
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options = opts.options or {}
      local transparent = opts.options.theme
      opts.options.theme = function()
        if vim.g.colors_name ~= "moonfly" then
          return type(transparent) == "function" and transparent() or transparent
        end
        local theme = require("lualine.utils.loader").load_theme("moonfly")
        for _, mode in pairs(theme) do
          for _, section in ipairs({ "b", "c" }) do
            if mode[section] then
              mode[section].bg = bar
            end
          end
        end
        return theme
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "moonfly",
    },
  },
}
