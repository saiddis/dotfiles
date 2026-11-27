-- snacks.indent bug (upstream, snacks.nvim indent.lua get_state): it reads a
-- window's sideways scroll with `nvim_buf_call(buf, winsaveview)`, which
-- picks *some* window showing the buffer (usually the current one), not the
-- window being drawn. With one file in two splits, a split scrolled sideways
-- then gets its indent guides placed as if it weren't scrolled, over the
-- code ("│mma" for "amma").
--
-- Fix without touching the plugin's files (lazy.nvim updates stay clean):
-- while snacks draws a window (its public `on_win`), that one call reads the
-- scroll of the window being drawn. Remove this file once upstream reads
-- `nvim_win_call(win, ...)` there.
return {
  "folke/snacks.nvim",
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        local ok, indent = pcall(require, "snacks.indent")
        if not ok or indent._leftcol_fixed then
          return
        end
        indent._leftcol_fixed = true
        local on_win = indent.on_win
        indent.on_win = function(win, buf, ...)
          local buf_call = vim.api.nvim_buf_call
          vim.api.nvim_buf_call = function(b, fn)
            if b == buf and fn == vim.fn.winsaveview and vim.api.nvim_win_is_valid(win) then
              return vim.api.nvim_win_call(win, fn)
            end
            return buf_call(b, fn)
          end
          local done, result = pcall(on_win, win, buf, ...)
          vim.api.nvim_buf_call = buf_call
          if not done then
            error(result, 0)
          end
          return result
        end
      end,
    })
  end,
}
