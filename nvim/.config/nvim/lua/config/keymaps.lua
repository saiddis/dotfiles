-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move lines. Hyprland owns ALT + J/K (window/workspace focus), so LazyVim's
-- <A-j>/<A-k> never arrive; these take counts and visual selections the same way.
local map = vim.keymap.set
map("n", "<leader>mj", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
map("n", "<leader>mk", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
map("x", "<leader>mj", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<leader>mk", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move selection up" })

-- Window splits and resizing from the old config (~/dotfiles/legacy/nvim, which-key.lua).
-- Splits open below / to the right (LazyVim's splitbelow and splitright).
map("n", "_", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "|", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<A-Up>", "<cmd>resize -1<cr>", { desc = "Resize up" })
map("n", "<A-Down>", "<cmd>resize +1<cr>", { desc = "Resize down" })
map("n", "<A-Left>", "<cmd>vertical resize -1<cr>", { desc = "Resize left" })
map("n", "<A-Right>", "<cmd>vertical resize +1<cr>", { desc = "Resize right" })

-- Half-page jumps keep the cursor line centred (old config, settings.lua)
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })

-- Diagnostic jumps without LazyVim's float: the message already shows after
-- the line the cursor lands on (diagnostics.lua). The float opens only when
-- that text doesn't show the diagnostic jumped to: it doesn't fit (a narrow
-- split), or the line has several and Neovim prints one message for them.
-- <leader>cd opens the float any time.
local function shown_after_line(d, bufnr)
  -- Draw the messages for the line the cursor is on now, then read back
  -- exactly what Neovim put after it
  vim.diagnostic.show(nil, bufnr)
  local text, shown = "", false
  -- as Neovim draws it after the line: "\r" dropped, "\n" as two spaces
  local wanted = d.message:gsub("\r", ""):gsub("\n", "  "):gsub("%s+$", "")
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { d.lnum, 0 }, { d.lnum, -1 }, { details = true })
  for _, mark in ipairs(marks) do
    if mark[4].virt_text_pos == "eol" then
      for _, chunk in ipairs(mark[4].virt_text or {}) do
        text = text .. chunk[1]
        -- each message is its own chunk (" message" after the markers);
        -- compare whole messages, so "known symbol" isn't found inside
        -- "unknown symbol"
        local message = chunk[1]:gsub("^%s+", ""):gsub("%s+$", "")
        if message == wanted then
          shown = true
        end
      end
    end
  end
  local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  -- the line as drawn, inlay hints (gopls `int`, `a...:`) included
  local width = (vim.fn.virtcol({ d.lnum + 1, "$" }) - 1) + vim.fn.strdisplaywidth(text)
  return shown and width <= info.width - info.textoff
end
-- The float, shaped like bento's menu and the picker: the editor black
-- inside a thin grey rounded line (DiagnosticFloatBorder), a space each side
-- of the text. Neovim sizes it for wrapping at any character; LazyVim's
-- linebreak wraps at word boundaries, which needs more rows (and cut the
-- last line to "@@@"), so it keeps the word wrapping and grows to the rows
-- it really takes. It closes when the cursor moves or focus leaves the
-- window, herdr pane or Ghostty window.
local function diagnostic_float(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    close_events = { "CursorMoved", "CursorMovedI", "InsertCharPre", "FocusLost", "WinLeave", "BufLeave" },
  })
  local _, win = vim.diagnostic.open_float(opts)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.wo[win].winhighlight = "NormalFloat:Normal"
    vim.wo[win].linebreak = true
    local config = vim.api.nvim_win_get_config(win)
    local width = math.min(config.width + 1, vim.o.columns - 2) -- the space on the right
    vim.api.nvim_win_set_config(win, { width = width })
    local rows = vim.api.nvim_win_text_height(win, {}).all
    local room = vim.o.lines - vim.o.cmdheight - 3
    vim.api.nvim_win_set_config(win, { height = math.max(1, math.min(rows, room)) })
  end
end
local function diagnostic_jump(count, severity)
  return function()
    vim.diagnostic.jump({
      count = count * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      on_jump = function(d, bufnr)
        if d and not shown_after_line(d, bufnr) then
          diagnostic_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end
      end,
    })
  end
end
vim.keymap.set("n", "<leader>cd", function()
  diagnostic_float()
end, { desc = "Line Diagnostics" })
vim.keymap.set("n", "]d", diagnostic_jump(1), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_jump(-1), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_jump(1, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_jump(-1, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_jump(1, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_jump(-1, "WARN"), { desc = "Prev Warning" })
