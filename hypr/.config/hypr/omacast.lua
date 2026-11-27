-- omacast is the one launcher: apps, commands, clipboard, emoji and themes.
-- Omarchy's own pickers for the same jobs are unbound so each job has one
-- chord and one look.

-- SUPER + SPACE stays Omarchy's root menu (settings, install, setup...): it is
-- not a launcher, and the Copilot-key alias Omarchy also binds is missing here.
-- SUPER + ALT + SPACE (was: Omarchy apps grid) now cycles the layout, bindings.lua
o.bind("ALT + D", "Launcher (omacast)", hl.dsp.global("omacast:toggle"), { submap_universal = true })

-- While omacast is open it switches Hyprland to this submap, so Super+J/K reach the launcher.
hl.define_submap("omacast", function()
  hl.bind("SUPER + F24", hl.dsp.no_op()) -- a submap needs one bind to exist
end)
-- Blur behind the launcher under Glassy Windows.
hl.layer_rule({ match = { namespace = "^omacast$" }, blur = true, ignore_alpha = 0.3 })

hl.unbind("SUPER + CTRL + V")         -- was: Omarchy clipboard manager
o.bind("ALT + V", "Clipboard history (omacast)", hl.dsp.global("omacast:clipboard"), { submap_universal = true })

hl.unbind("SUPER + CTRL + T")
hl.unbind("SUPER + SHIFT + CTRL + SPACE") -- was: Omarchy theme menu
o.bind("SUPER + CTRL + T", "Switch theme (omacast)", hl.dsp.global("omacast:theme"), { submap_universal = true })

hl.unbind("SUPER + CTRL + E")         -- was: Omarchy emoji picker
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + E", "Emoji & symbols (omacast)", hl.dsp.global("omacast:emoji"), { submap_universal = true })
