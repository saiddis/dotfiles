-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Splits on a terminal resize (herdr zoom, a neighbouring herdr pane
-- resized, ALT + F): equal splits stay equal, as in the old config
-- (`VimResized * wincmd =`); splits you sized by hand keep their
-- proportions instead of snapping back to halves (Vim alone would squeeze
-- the last split). Windows with a fixed size (file trees) are left alone.
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_resize_splits")
do
  local shares = {} -- tabpage -> { [win] = { width share, height share } }, only when sized by hand

  local function extent(node, dim)
    if node[1] == "leaf" then
      return dim == "width" and vim.api.nvim_win_get_width(node[2]) or vim.api.nvim_win_get_height(node[2])
    end
    if (node[1] == "row") ~= (dim == "width") then
      return extent(node[2][1], dim)
    end
    local total = #node[2] - 1 -- separators
    for _, child in ipairs(node[2]) do
      total = total + extent(child, dim)
    end
    return total
  end

  local function fixed(node, dim)
    return node[1] == "leaf" and vim.wo[node[2]][dim == "width" and "winfixwidth" or "winfixheight"]
  end

  local function balanced(node)
    if node[1] == "leaf" then
      return true
    end
    local dim = node[1] == "row" and "width" or "height"
    local lo, hi = math.huge, -math.huge
    for _, child in ipairs(node[2]) do
      if not fixed(child, dim) then
        local size = extent(child, dim)
        lo, hi = math.min(lo, size), math.max(hi, size)
      end
      if not balanced(child) then
        return false
      end
    end
    return lo == math.huge or hi - lo <= 1
  end

  local function leaves(node, out)
    if node[1] == "leaf" then
      table.insert(out, node[2])
    else
      for _, child in ipairs(node[2]) do
        leaves(child, out)
      end
    end
    return out
  end

  -- Sizes this code set itself: a WinResized that finds exactly these is
  -- not a hand resize (Neovim can't always split evenly, e.g. two splits in
  -- 39 columns), so it changes nothing
  local applied = {} -- tabpage -> signature

  local function signature(layout)
    local parts = {}
    for _, win in ipairs(leaves(layout, {})) do
      parts[#parts + 1] = win .. ":" .. vim.api.nvim_win_get_width(win) .. "x" .. vim.api.nvim_win_get_height(win)
    end
    return table.concat(parts, " ")
  end

  local function fit(tab)
    local saved = shares[tab]
    if not saved then
      -- LazyVim's winwidth 20 holds the current window at 20 columns and
      -- makes `wincmd =` uneven at some widths; lower it for the call
      local winwidth = vim.o.winwidth
      vim.o.winwidth = vim.o.winminwidth
      vim.cmd("wincmd =")
      vim.o.winwidth = winwidth
    else
      local layout = vim.fn.winlayout()
      local w, h = extent(layout, "width"), extent(layout, "height")
      -- twice: each set takes its space from a neighbour
      for _ = 1, 2 do
        for win, share in pairs(saved) do
          if vim.api.nvim_win_is_valid(win) then
            if not vim.wo[win].winfixwidth then
              vim.api.nvim_win_set_width(win, math.max(1, math.floor(share[1] * w + 0.5)))
            end
            if not vim.wo[win].winfixheight then
              vim.api.nvim_win_set_height(win, math.max(1, math.floor(share[2] * h + 0.5)))
            end
          end
        end
      end
    end
    applied[tab] = signature(vim.fn.winlayout())
  end

  local stale = {} -- tabpages resized while in the background
  local group = vim.api.nvim_create_augroup("resize_splits_keep_manual", { clear = true })
  vim.api.nvim_create_autocmd("WinResized", {
    group = group,
    callback = function()
      local ok, layout = pcall(vim.fn.winlayout)
      if not ok then
        return
      end
      local tab = vim.api.nvim_get_current_tabpage()
      if applied[tab] == signature(layout) then
        return -- our own sizes: keep what was remembered (no rounding drift)
      end
      applied[tab] = nil
      if balanced(layout) then
        shares[tab] = nil
        return
      end
      local w, h = extent(layout, "width"), extent(layout, "height")
      shares[tab] = {}
      for _, win in ipairs(leaves(layout, {})) do
        shares[tab][win] = { vim.api.nvim_win_get_width(win) / w, vim.api.nvim_win_get_height(win) / h }
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      -- The current tab now; the others when next entered (switching tabs
      -- here would fire their Enter autocommands on every resize step)
      local current = vim.api.nvim_get_current_tabpage()
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        stale[tab] = tab ~= current or nil
      end
      fit(current)
    end,
  })
  vim.api.nvim_create_autocmd("TabEnter", {
    group = group,
    callback = function()
      local tab = vim.api.nvim_get_current_tabpage()
      if stale[tab] then
        stale[tab] = nil
        fit(tab)
      end
    end,
  })
end

-- A split that was narrow enough to scroll sideways (sidescrolloff, inlay
-- hints) scrolls back to the first column once it is wide enough again;
-- Neovim alone leaves the first characters of every line hidden.
vim.api.nvim_create_autocmd("WinResized", {
  group = vim.api.nvim_create_augroup("resize_unscroll", { clear = true }),
  callback = function()
    for _, win in ipairs(vim.v.event.windows or {}) do
      if vim.api.nvim_win_is_valid(win) and not vim.wo[win].wrap then
        vim.api.nvim_win_call(win, function()
          local view = vim.fn.winsaveview()
          if view.leftcol > 0 then
            local info = vim.fn.getwininfo(win)[1]
            local room = info.width - info.textoff
            -- the cursor's column as drawn (virtcol counts inlay hints)
            local cursor = vim.fn.virtcol(".")
            -- scroll back as far as keeps the cursor in view (all the way
            -- once it fits)
            local leftcol = math.max(0, cursor + vim.wo[win].sidescrolloff - room)
            if leftcol < view.leftcol then
              vim.fn.winrestview({ leftcol = leftcol })
            end
          end
        end)
      end
    end
  end,
})
