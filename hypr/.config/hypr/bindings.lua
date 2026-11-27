-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Templates: o.bind adds a binding, o.rebind replaces one (same arguments),
-- hl.unbind("SUPER + X") removes one. Every live chord is listed by SUPER + K.

---------------------------------------------------------------------------
-- Niri-style window management on ALT, the thumb modifier, so Omarchy's
-- SUPER defaults (apps, menus, system) stay as they are. One grammar:
--
--   ALT + h/j/k/l            go: column left/right, window down/up in the
--                            column, and past the column's end to the next
--                            workspace below/above that has windows (like
--                            niri; going down also reaches one empty
--                            workspace after the last busy one)
--   ALT + SHIFT + h/j/k/l    take the focused window the same way
--   ALT + CTRL + h/j/k/l     resize it: narrower/taller/shorter/wider
--   ALT + F                  full / half width     F11  true full screen
--   SUPER + N                first empty workspace ("new")
--   ALT + O                  overview of every window (Exposé)
--   ALT + D / ALT + V        launcher / clipboard history (omacast.lua)
--
-- One layer down, herdr (~/dotfiles/herdr) repeats the grammar on CTRL for
-- splits: CTRL + h/j/k/l moves between panes and Neovim splits
-- (herdr-splits), CTRL + SHIFT + h/j/k/l swaps panes, CTRL + ALT + SHIFT +
-- h/j/k/l resizes. It also keeps ALT + N/P (its workspaces), ALT + 1..9
-- (tabs) and ALT + E/I/Y (its navigator), so those stay free here.
-- ALT + J/K take LazyVim's move-line, which lives on <leader>mj / <leader>mk
-- instead (nvim keymaps.lua). ALT + SHIFT + L takes Omarchy's "Copy URL"
-- web-app shortcut (its toolbar button still works); keybindings-menu
-- (SUPER + K, below) drops that hard-coded row from the sheet.
---------------------------------------------------------------------------

local slots = o.workspaces.slots

local function slot_of(id)
  return (id - 1) % slots + 1
end

-- The next workspace slot in direction `dir` (1 = down, -1 = up) on the
-- focused monitor, skipping empty ones. Going down, when nothing busy is left,
-- it stops at the first empty slot after a busy workspace, so there is always
-- one fresh workspace at the end and never a run of blank ones (like niri).
local function slot_step(dir)
  local workspace, monitor = hl.get_active_workspace(), hl.get_active_monitor()
  if not workspace or workspace.id <= 0 or not monitor then
    return nil
  end
  local busy = {}
  for _, ws in ipairs(hl.get_workspaces()) do
    if ws.id > 0 and (ws.windows or 0) > 0 then
      busy[ws.id] = true
    end
  end
  local current = slot_of(workspace.id)
  local slot = current + dir
  while slot >= 1 and slot <= slots do
    if busy[o.workspaces.workspace_id(monitor, slot)] then
      return slot
    end
    slot = slot + dir
  end
  if dir > 0 and current < slots and busy[workspace.id] then
    return current + 1
  end
  return nil
end

-- The nearest tiled window stacked above (dir = -1) or below (dir = 1) the
-- focused one in its column, if any.
local function column_neighbour(dir)
  local window = hl.get_active_window()
  if not window or window.floating then
    return nil
  end
  local left, right = window.at.x, window.at.x + window.size.x
  local best, best_distance
  for _, other in ipairs(hl.get_workspace_windows(window.workspace.id)) do
    if other.address ~= window.address and not other.floating then
      local overlap = math.min(right, other.at.x + other.size.x) - math.max(left, other.at.x)
      local distance = (other.at.y - window.at.y) * dir
      if overlap > window.size.x / 2 and distance > 0 and (not best_distance or distance < best_distance) then
        best, best_distance = other, distance
      end
    end
  end
  return best
end

-- ALT + J/K: through the column's stack first, then on to the next workspace.
local function focus_vertical(dir)
  return function()
    if column_neighbour(dir) then
      hl.dispatch(hl.dsp.focus({ direction = dir > 0 and "d" or "u" }))
      return
    end
    local slot = slot_step(dir)
    if slot then
      o.workspaces.focus(slot)()
    end
  end
end

-- ALT + SHIFT + J/K: the same path, carrying the focused window along.
local function move_vertical(dir)
  return function()
    if column_neighbour(dir) then
      hl.dispatch(hl.dsp.window.move({ direction = dir > 0 and "d" or "u" }))
      return
    end
    local slot = slot_step(dir)
    if slot and hl.get_active_window() then
      o.workspaces.move_window(slot)()
    end
  end
end

local function first_empty_workspace()
  local monitor = hl.get_active_monitor()
  if not monitor then
    return
  end
  local busy = {}
  for _, workspace in ipairs(hl.get_workspaces()) do
    if workspace.id > 0 and (workspace.windows or 0) > 0 then
      busy[workspace.id] = true
    end
  end
  for slot = 1, slots do
    if not busy[o.workspaces.workspace_id(monitor, slot)] then
      o.workspaces.focus(slot)()
      return
    end
  end
end

-- Go
-- ALT + H / L stop at the first and last column, like herdr-splits at its
-- outer edge. Hyprland's directional focus wraps round to the far column there
-- (scrolling:wrap_focus doesn't cover it), which made two columns a toggle.
local function focus_column(dir)
  return function()
    local window = hl.get_active_window()
    if window and not window.floating then
      local beyond = false
      for _, other in ipairs(hl.get_workspace_windows(window.workspace.id)) do
        if other.address ~= window.address and not other.floating then
          if (dir == "l" and other.at.x + other.size.x <= window.at.x)
            or (dir == "r" and other.at.x >= window.at.x + window.size.x) then
            beyond = true
            break
          end
        end
      end
      if not beyond then
        return
      end
    end
    hl.dispatch(hl.dsp.focus({ direction = dir }))
  end
end
o.rebind("ALT + H", "Focus column left", focus_column("l"))
o.rebind("ALT + L", "Focus column right", focus_column("r"))
-- Three-finger horizontal swipe does the same, stopping at the edge columns.
-- Vertical three-finger swipes change workspace (input.lua).
hl.gesture({ fingers = 3, direction = "left", action = focus_column("l") })
hl.gesture({ fingers = 3, direction = "right", action = focus_column("r") })
o.rebind("ALT + J", "Focus down (or workspace)", focus_vertical(1))
o.rebind("ALT + K", "Focus up (or workspace)", focus_vertical(-1))
o.rebind("SUPER + N", "Go to first empty workspace", first_empty_workspace)

-- The scrolling layout keeps the view where it was when a column ends up last
-- and narrower than the screen (halved by ALT + F, or a window moved into it):
-- the column at the left edge, wallpaper beside it, its neighbour off-screen.
-- Once the layout settles, touch the left neighbour and refocus the same
-- window by address, so the view takes both (niri does this on its own).
local function fill_view()
  local window = hl.get_active_window()
  if not window or window.floating then
    return
  end
  local target = "address:" .. window.address
  hl.timer(function()
    local w = hl.get_window(target)
    local workspace = w and hl.get_active_workspace()
    if not w or w.floating or not workspace or workspace.tiled_layout ~= "scrolling" then
      return
    end
    local monitor = w.monitor
    local reserved = monitor.reserved or {}
    local right_edge = monitor.x + monitor.width / monitor.scale - (reserved.right or 0)
    local has_left, has_right = false, false
    for _, other in ipairs(hl.get_workspace_windows(w.workspace.id)) do
      if other.address ~= w.address and not other.floating then
        if other.at.x + other.size.x <= w.at.x then
          has_left = true
        elseif other.at.x >= w.at.x + w.size.x then
          has_right = true
        end
      end
    end
    -- Only when half a screen or more beside it is empty
    if has_left and not has_right and right_edge - (w.at.x + w.size.x) > w.size.x / 2 then
      hl.dispatch(hl.dsp.layout("focus l"))
      hl.dispatch(hl.dsp.focus({ window = target }))
    end
  end, { timeout = 1, type = "oneshot" })
end

-- Take the window along. On the scrolling layout H/L join or leave the
-- neighbouring column, like the old hyprscrolling `movewindowto`.
local function move_column(dir)
  return function()
    hl.dispatch(hl.dsp.window.move({ direction = dir }))
    fill_view()
  end
end
o.rebind("ALT + SHIFT + H", "Move window to column left", move_column("l"))
o.rebind("ALT + SHIFT + L", "Move window to column right", move_column("r"))
o.rebind("ALT + SHIFT + J", "Move window down (or workspace)", move_vertical(1))
o.rebind("ALT + SHIFT + K", "Move window up (or workspace)", move_vertical(-1))

-- Resize (held keys repeat)
local resize = function(x, y)
  return hl.dsp.window.resize({ x = x, y = y, relative = true })
end
o.rebind("ALT + CTRL + H", "Make window narrower", resize(-40, 0), { repeating = true })
o.rebind("ALT + CTRL + L", "Make window wider", resize(40, 0), { repeating = true })
o.rebind("ALT + CTRL + J", "Make window taller", resize(0, 40), { repeating = true })
o.rebind("ALT + CTRL + K", "Make window shorter", resize(0, -40), { repeating = true })

-- Overview of every window, all workspaces (type to filter, Enter to go)
o.rebind("ALT + O", "Overview (Exposé)", "omarchy-shell expose toggle")

-- True full screen on F11 (SUPER + F is freed below)
o.rebind("F11", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- No dictation toggle on ALT + SPACE (push-to-talk on Right Alt still works)
hl.unbind("ALT + SPACE")

-- Scroll through workspaces with ALT + wheel instead of SUPER + wheel
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.rebind("ALT + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "m+1" }))
o.rebind("ALT + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "m-1" }))

-- Alt+Shift, pressed and released on its own, switches English <-> Russian.
-- fcitx5 does the typing, so this switches its input method; English stays the
-- default for every new window. A release bind is skipped when another key is
-- pressed during the hold, so ALT + SHIFT + H/J/K/L still only move windows.
-- The OSD names the method fcitx actually landed on (fcitx's own popup is off,
-- ~/.config/fcitx5/config), in the same place every time. With no focused
-- window fcitx has no input to switch, and the OSD says so.
local switch_layout = [[sh -c 'case $(fcitx5-remote -n) in "") omarchy osd -i keyboard -m "No text input" -d 900; exit ;; keyboard-ru) fcitx5-remote -s keyboard-us ;; *) fcitx5-remote -s keyboard-ru ;; esac; case $(fcitx5-remote -n) in keyboard-ru) l=RU ;; *) l=EN ;; esac; omarchy osd -i keyboard -m "$l" -d 700']]
-- As in Hyprland's SUPER + Super_L tap example, a modifier key's own modifier
-- counts as held, so both keys carry ALT + SHIFT. Each order arms only one.
o.bind("ALT + SHIFT + Shift_L", "Switch keyboard layout (en/ru)", switch_layout, { release = true })
o.bind("ALT + SHIFT + Alt_L", "Switch keyboard layout (en/ru)", switch_layout, { release = true })

-- ALT + F, like niri's maximize-column: on a scrolling workspace the column
-- switches between the full width of the workspace and half of it. On other
-- layouts it toggles Omarchy's full width. F11 stays true full screen.
local function toggle_full_width()
  local window = hl.get_active_window()
  if not window then
    return
  end
  local workspace = hl.get_active_workspace()
  if window.floating or not workspace or workspace.tiled_layout ~= "scrolling" then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
    return
  end
  local monitor = window.monitor
  local reserved = monitor.reserved or {}
  local usable = monitor.width / monitor.scale - (reserved.left or 0) - (reserved.right or 0)
  local wide = (window.size.x or 0) >= usable * 0.75
  hl.dispatch(hl.dsp.layout(wide and "colresize 0.5" or "colresize 1.0"))
  if wide then
    fill_view()
  end
end

-- Replaces SUPER + F (was: Full screen, which F11 also does).
hl.unbind("SUPER + F")
o.bind("ALT + F", "Full width / half width", toggle_full_width)

-- No dock (the launcher and ALT + O cover it), so
-- minimising would hide a window with nowhere to bring it back from.
hl.unbind("SUPER + M")

-- One chord per job:
hl.unbind("SUPER + ALT + F")        -- Full width: ALT + F does it
hl.unbind("SUPER + ALT + RETURN")   -- Tmux: herdr is on SUPER + CTRL + RETURN
hl.unbind("SUPER + ALT + K")        -- Tmux keybindings
-- Cycling the layout also saves it for that workspace, so it moves off the
-- vim keys to the apps-grid chord the launcher freed (omacast.lua).
hl.unbind("SUPER + ALT + L")
-- Lock moves from SUPER + CTRL + L to SUPER + L.
hl.unbind("SUPER + CTRL + L")
o.rebind("SUPER + L", "Lock system", "omarchy-system-lock")
o.rebind("SUPER + ALT + SPACE", "Cycle workspace layout (saved per workspace)", "omarchy-hyprland-workspace-layout-toggle")

-- SUPER + T: a window that starts floating lands centred, not wherever its
-- tile was (which could hang past the bottom gap). Floating it back goes home:
-- the scrolling layout re-inserts an unfloated window as a new column beside
-- its old one, so a window that was stacked in a column is moved back into that
-- column (the same move as ALT + SHIFT + H/L) and up to its old place in the
-- stack. The float state is only set after this loop, so both wait one, as in
-- Omarchy's pop.lua.
local float_home = {} -- address -> { below = address of the window under it, or nil, anchor = address }
o.rebind("SUPER + T", "Toggle window floating/tiling", function()
  local window = hl.get_active_window()
  if not window then
    return
  end
  local target = "address:" .. window.address
  if not window.floating then
    local above, below = column_neighbour(-1), column_neighbour(1)
    local anchor = above or below
    float_home[window.address] = anchor and { anchor = anchor.address, below = below and below.address } or nil
  end
  hl.dispatch(hl.dsp.window.float({ action = "toggle", window = target }))
  hl.timer(function()
    local w = hl.get_window(target)
    if not w then
      return
    end
    if w.floating then
      hl.dispatch(hl.dsp.window.center({ window = target }))
      return
    end
    local home = float_home[w.address]
    float_home[w.address] = nil
    local anchor = home and hl.get_window("address:" .. home.anchor)
    if not anchor or anchor.floating or anchor.workspace.id ~= w.workspace.id then
      return
    end
    -- Only when the old column is right next to the new one; anything
    -- further would merge into the wrong column.
    local dir = anchor.at.x < w.at.x and "l" or "r"
    for _, other in ipairs(hl.get_workspace_windows(w.workspace.id)) do
      local x = other.at.x
      if not other.floating and x ~= anchor.at.x and x ~= w.at.x
        and (x - anchor.at.x) * (x - w.at.x) < 0 then
        return
      end
    end
    hl.dispatch(hl.dsp.window.move({ direction = dir, window = target }))
    -- It joins at the bottom of the column: climb back above the window that
    -- used to be under it.
    if home.below then
      for _ = 1, 8 do
        local me, under = hl.get_window(target), hl.get_window("address:" .. home.below)
        if not me or not under or under.floating or me.at.y < under.at.y then
          break
        end
        hl.dispatch(hl.dsp.window.move({ direction = "u", window = target }))
      end
    end
  end, { timeout = 1, type = "oneshot" })
end)

-- Duplicates of the ALT grammar above, so the cheat sheet lists one chord per
-- job: SUPER + arrows focus (ALT + hjkl), SUPER + SHIFT + arrows swap
-- (ALT + SHIFT + hjkl), SUPER (+ ALT/CTRL/SHIFT) + MINUS/EQUAL resize
-- (ALT + CTRL + hjkl). SUPER + J toggled a dwindle split, which does nothing
-- on the scrolling layout.
for _, dir in ipairs({ "LEFT", "RIGHT", "UP", "DOWN" }) do
  hl.unbind("SUPER + " .. dir)
  hl.unbind("SUPER + SHIFT + " .. dir)
end
for _, mods in ipairs({ "SUPER", "SUPER + SHIFT", "SUPER + ALT", "SUPER + SHIFT + ALT", "SUPER + CTRL", "SUPER + CTRL + SHIFT" }) do
  hl.unbind(mods .. " + code:20")
  hl.unbind(mods .. " + code:21")
end
hl.unbind("SUPER + J")

-- Omarchy's CTRL + SPACE drops fcitx back to direct input in terminals, for a
-- tmux/herdr prefix on that chord. herdr's prefix here is CTRL + B, so it only
-- flipped Russian back to English on Neovim's completion key.
hl.unbind("CTRL + SPACE")

-- Push-to-talk is one row on the cheat sheet: the release half (stop) is
-- bound without a description, as the sheet skips those.
if o.dictation_installed() then
  hl.unbind("ALT + Alt_R")
  o.bind_hold("ALT + Alt_R", "Dictation (hold to talk)", "omarchy-dictation start", "", "omarchy-dictation stop", { ignore_mods = true })
end

-- herdr cheat sheet that also lists the [[keys.command]] binds (Ctrl + hjkl,
-- navigator) and prints shifted keys as symbols (~/.local/bin).
o.rebind("SUPER + CTRL + K", "Herdr keybindings", os.getenv("HOME") .. "/.local/bin/herdr-keybindings-menu")

-- SUPER + K: Omarchy's sheet without its hard-coded web-app rows (not real
-- binds here), with same-job chords merged and the ALT layer first (~/.local/bin).
o.rebind("SUPER + K", "Keybindings", os.getenv("HOME") .. "/.local/bin/keybindings-menu")

-- The ALT + SHIFT tap above already switches en/ru; Omarchy's SUPER + I and
-- SUPER + SHIFT + I cycled the same two fcitx input methods.
hl.unbind("SUPER + I")
hl.unbind("SUPER + SHIFT + I")
