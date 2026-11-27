-- Lualine theme for the Omarchy "Moonfly" theme. Overrides moonfly's own
-- lualine theme (which hardcodes stock colours) with the customised palette,
-- so it follows the theme's colors.toml. Only used while moonfly is active.
local p = require("moonfly").palette

local function mode(color)
  return { a = { bg = color, fg = p.background or "#000000", gui = "bold" }, b = { bg = p.grey18, fg = color } }
end

local theme = {
  normal = mode(p.blue), -- accent
  insert = mode(p.emerald), -- emerald, as in moonfly's own lualine theme
  visual = mode(p.purple), -- violet
  command = mode(p.yellow), -- orange
  replace = mode(p.crimson),
  terminal = mode(p.emerald),
  inactive = {
    a = { bg = p.grey18, fg = p.grey58 },
    b = { bg = p.grey18, fg = p.grey58 },
    c = { bg = p.grey7, fg = p.grey58 },
  },
}
theme.normal.c = { bg = p.grey7, fg = p.white }
return theme
