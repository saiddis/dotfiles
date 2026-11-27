-- Diagnostic messages after the line: errors always show; warnings, info and
-- hints show only while the cursor is on their line, so the screen stays quiet
-- until you look at one. Signs and underlines (coloured per severity in the
-- Moonfly theme's neovim.lua) still mark every problem.
local ERROR = vim.diagnostic.severity.ERROR

local function on_cursor_line(d)
  local win = vim.api.nvim_get_current_win()
  return vim.api.nvim_win_get_buf(win) == d.bufnr and vim.api.nvim_win_get_cursor(win)[1] - 1 == d.lnum
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- The float (]d in a narrow split, <leader>cd): a thin rounded grey
        -- frame like bento's and the picker's, no "Diagnostics:" heading
        float = {
          header = "",
          -- Numbered only when there are several ("1." on a lone message is
          -- noise), and a space off the frame
          prefix = function(_, i, total)
            return total > 1 and (" " .. i .. ". ") or " "
          end,
          border = vim.tbl_map(function(c)
            return { c, "DiagnosticFloatBorder" }
          end, { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }),
        },
        virtual_text = {
          -- No "Lua Diagnostics.:" prefix when two sources report on a
          -- buffer; the float (<leader>cd) still names the source
          source = false,
          -- Returning nil hides that diagnostic's message (Neovim's own
          -- renderer, so prefix, spacing and colours stay as they are)
          format = function(d)
            if d.severity == ERROR or on_cursor_line(d) then
              return d.message
            end
            return nil
          end,
        },
      },
    },
    init = function()
      -- Underlines: language servers often report a position, not a range
      -- (gopls marks the first letter of `listener`, or the `h` ending
      -- `kjfhgkjh` for a syntax error). A squiggle one cell wide reads as a
      -- caret, so a range of one character or less is drawn under the whole
      -- word it touches. Only the drawing changes; jumps, code actions and
      -- the diagnostic itself keep the server's position.
      local function widen(bufnr, d)
        if (d.end_lnum or d.lnum) ~= d.lnum or (d.end_col or d.col) - d.col > 1 then
          return d
        end
        local line = vim.api.nvim_buf_get_lines(bufnr, d.lnum, d.lnum + 1, false)[1]
        if not line then
          return d
        end
        local is_word = function(i)
          return i >= 1 and i <= #line and line:sub(i, i):match("[%w_]") ~= nil
        end
        local s = d.col + 1 -- 1-based
        if not is_word(s) then
          if is_word(s - 1) then -- position just past the word's end
            s = s - 1
          else
            return d
          end
        end
        local first, last = s, s
        while is_word(first - 1) do
          first = first - 1
        end
        while is_word(last + 1) do
          last = last + 1
        end
        return vim.tbl_extend("force", {}, d, { col = first - 1, end_col = last, end_lnum = d.lnum })
      end
      -- A range still one cell wide after that (a one-letter name like `b`)
      -- gets a straight underline in the severity colour: a curl one cell
      -- wide reads as a caret.
      local names = { "Error", "Warn", "Info", "Hint" }
      local function cell_group(severity)
        local name = "DiagnosticUnderline" .. names[severity] .. "Cell"
        local base = vim.api.nvim_get_hl(0, { name = "DiagnosticUnderline" .. names[severity], link = false })
        vim.api.nvim_set_hl(0, name, { underline = true, sp = base.sp })
        return name
      end
      local cell_ns = {} -- diagnostic namespace -> our extmark namespace
      local function cells(namespace)
        cell_ns[namespace] = cell_ns[namespace]
          or vim.api.nvim_create_namespace("diagnostic_cell_underline_" .. namespace)
        return cell_ns[namespace]
      end

      local underline = vim.diagnostic.handlers.underline
      vim.diagnostic.handlers.underline = {
        show = function(namespace, bufnr, diagnostics, opts)
          local drawn, single = {}, {}
          for _, d in ipairs(diagnostics) do
            local w = widen(bufnr, d)
            if (w.end_lnum or w.lnum) == w.lnum and (w.end_col or w.col) - w.col <= 1 then
              table.insert(single, w)
            else
              table.insert(drawn, w)
            end
          end
          underline.show(namespace, bufnr, drawn, opts)
          local ns = cells(namespace)
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
          for _, d in ipairs(single) do
            local groups = { cell_group(d.severity) }
            if d._tags and d._tags.unnecessary then
              table.insert(groups, "DiagnosticUnnecessary")
            end
            if d._tags and d._tags.deprecated then
              table.insert(groups, "DiagnosticDeprecated")
            end
            local line = vim.api.nvim_buf_get_lines(bufnr, d.lnum, d.lnum + 1, false)[1] or ""
            local col = math.max(0, math.min(d.col, #line - 1))
            for _, group in ipairs(groups) do
              vim.hl.range(bufnr, ns, group, { d.lnum, col }, { d.lnum, col + 1 }, {
                priority = vim.hl.priorities.diagnostics + (4 - d.severity),
              })
            end
          end
        end,
        hide = function(namespace, bufnr)
          underline.hide(namespace, bufnr)
          if cell_ns[namespace] and vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_clear_namespace(bufnr, cell_ns[namespace], 0, -1)
          end
        end,
      }

      -- Redraw the messages when the cursor moves to another line, and in
      -- the buffer it just left when it moves to another split or buffer
      -- (else that buffer keeps the warning it was on)
      local function redraw(buf)
        if
          vim.api.nvim_buf_is_valid(buf)
          and #vim.diagnostic.get(buf, { severity = { max = vim.diagnostic.severity.WARN } }) > 0
        then
          vim.diagnostic.show(nil, buf)
        end
      end
      local last, left = {}, nil
      local group = vim.api.nvim_create_augroup("diagnostics_cursor_line", { clear = true })
      vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        group = group,
        callback = function(ev)
          left = ev.buf
        end,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinEnter", "InsertLeave" }, {
        group = group,
        callback = function(ev)
          local win = vim.api.nvim_get_current_win()
          local line = vim.api.nvim_win_get_cursor(win)[1]
          if ev.event == "CursorMoved" and last[win] == line then
            return
          end
          last[win] = line
          if left and left ~= ev.buf then
            redraw(left)
          end
          left = nil
          redraw(ev.buf)
        end,
      })
    end,
  },
  {
    -- `]w` with nothing left to jump to: Neovim's warning goes to the small
    -- corner view instead of a full notice box
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      table.insert(opts.routes, { filter = { event = "msg_show", find = "No more valid diagnostics" }, view = "mini" })
    end,
  },
}
