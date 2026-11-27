local active_border_color = "rgba(80a0ffe6)"
local inactive_border_color = "rgba(2e2e2eff)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

-- Moonfly look, added by sync-overrides.py: flat rounded windows, a soft
-- shadow, and a 2px border that is moonfly blue on the focused window and a
-- hairline grey elsewhere. Group tabs use the same font and accent.
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
  },

  decoration = {
    rounding = 10,
    rounding_power = 3,

    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      offset = "0 4",
      color = "rgba(00000099)",
      color_inactive = "rgba(00000055)",
    },
  },

  group = {
    groupbar = {
      font_family = "JetBrainsMono Nerd Font",
      font_size = 11,
      font_weight_active = "bold",
      font_weight_inactive = "normal",
      height = 20,
      indicator_height = 2,
      gradients = false,
      text_color = "rgb(BDBDBD)",
      text_color_inactive = "rgb(949494)",
      col = {
        active = "rgb(80A0FF)",
        inactive = "rgb(2E2E2E)",
      },
    },
  },
})
