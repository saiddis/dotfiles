-- Strudel live coding (strudel.cc, TidalCycles patterns in JavaScript) from
-- Neovim: bonzonkim/strudel.nvim. A Node bridge runs strudel.cc in a headless
-- Chromium (Omarchy's own, so npm doesn't download a second browser); code
-- goes to it over OSC (UDP 9129), the sound plays from the browser, and the
-- notes that sound flash in the buffer.
--
-- Files ending in .str or .strudel open as Strudel (JavaScript highlighting,
-- no JavaScript language server or linter, Strudel completions). In those
-- buffers only, keys under the local leader (\):
--   \S start the bridge (first, ~5 s while strudel.cc loads)
--   Ctrl+E / \f  play the whole file (what Ctrl+Enter does on strudel.cc)
--   \e  play the line, or the selection in visual mode
--   \s  stop the sound (hush)
--   \q  stop the bridge (quitting Neovim stops it too)
-- Don't end patterns with .play(): the bridge plays what is evaluated.
-- Global <leader>s stays LazyVim's search: the plugin's own <leader>s keys
-- (set in every buffer) are never loaded.

vim.filetype.add({ extension = { str = "strudel", strudel = "strudel" } })

local function strudel()
  return require("strudel")
end

local function running()
  if strudel().bridge_job_id then
    return true
  end
  vim.notify("Strudel bridge isn't running: \\S starts it", vim.log.levels.WARN, { title = "Strudel" })
  return false
end

local function start()
  -- Omarchy's Chromium unless PUPPETEER_EXECUTABLE_PATH already names one;
  -- set only for the bridge, not for everything else Neovim starts
  local saved = vim.env.PUPPETEER_EXECUTABLE_PATH
  if not saved and vim.fn.executable("chromium") == 1 then
    vim.env.PUPPETEER_EXECUTABLE_PATH = vim.fn.exepath("chromium")
  end
  strudel().start_bridge()
  vim.env.PUPPETEER_EXECUTABLE_PATH = saved
end

local function play(fn)
  return function()
    if running() then
      fn()
    end
  end
end

return {
  {
    "bonzonkim/strudel.nvim",
    ft = "strudel",
    cmd = { "StrudelStart", "StrudelStopBridge", "StrudelEval", "StrudelEvalFile", "StrudelStop" },
    -- With Chromium on the system, Puppeteer skips its own ~170 MB browser
    build = function(plugin)
      local env = vim.fn.executable("chromium") == 1 and { PUPPETEER_SKIP_DOWNLOAD = "1" } or nil
      local res = vim.system({ "npm", "install", "--prefix", "osc-bridge" }, { cwd = plugin.dir, env = env }):wait()
      if res.code ~= 0 then
        error("npm install failed:\n" .. (res.stderr or ""))
      end
    end,
    init = function()
      -- Skip the plugin's plugin/strudel.lua: it maps <leader>se/sf/ss/sS/sq
      -- /sv/sh in every buffer, over LazyVim's search keys (<leader>ss
      -- symbols, <leader>sh help, <leader>sq quickfix). Commands and
      -- buffer-local keys come from config below instead.
      vim.g.loaded_strudel_plugin = true
      vim.treesitter.language.register("javascript", "strudel")
    end,
    config = function()
      local s = strudel()
      s.setup()

      local command = vim.api.nvim_create_user_command
      command("StrudelStart", start, { desc = "Start the Strudel bridge" })
      command("StrudelStopBridge", s.stop_bridge, { desc = "Stop the Strudel bridge" })
      command("StrudelStop", play(s.stop), { desc = "Stop the sound (hush)" })
      command("StrudelEvalFile", play(s.eval_file), { desc = "Play the file" })
      command("StrudelEval", function(opts)
        if running() then
          if opts.range > 0 then
            s.eval_visual()
          else
            s.eval_line()
          end
        end
      end, { range = true, desc = "Play the line or range" })

      local function buffer(buf)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        vim.bo[buf].commentstring = "// %s"
        map("n", "<localleader>S", start, "Start bridge")
        map("n", "<localleader>q", s.stop_bridge, "Stop bridge")
        map("n", "<C-e>", play(s.eval_file), "Play file")
        map("n", "<localleader>f", play(s.eval_file), "Play file")
        map("n", "<localleader>e", play(s.eval_line), "Play line")
        -- <Esc> first, so '< and '> mark this selection, then pass them as the range
        map("x", "<localleader>e", "<Esc><Cmd>'<,'>StrudelEval<CR>", "Play selection")
        map("x", "<C-e>", "<Esc><Cmd>'<,'>StrudelEval<CR>", "Play selection")
        map("n", "<localleader>s", play(s.stop), "Stop sound (hush)")
      end
      local group = vim.api.nvim_create_augroup("strudel_buffers", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "strudel",
        callback = function(ev)
          buffer(ev.buf)
        end,
      })
      -- The buffer that triggered loading has had its FileType already
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "strudel" then
          buffer(buf)
        end
      end
      -- A theme change (Omarchy hot reload) clears the flash colours the
      -- plugin made; forget them so it makes them again
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          require("strudel.visual").hl_cache = {}
        end,
      })
    end,
  },
  {
    -- Strudel's completion source is written for nvim-cmp; blink.compat
    -- serves it to blink.cmp, only in Strudel buffers (not in every
    -- JavaScript file)
    "saghen/blink.compat",
    lazy = true,
    opts = {},
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = { strudel = { inherit_defaults = true, "strudel" } },
        -- blink.compat finds the source by this name: the one the plugin
        -- registers (cmp_name), shown capitalised in the menu
        providers = {
          strudel = { name = "Strudel", module = "blink.compat.source", opts = { cmp_name = "strudel" } },
        },
      },
    },
  },
  {
    -- The bridge's progress lines ("Strudel loaded!", "Playing..." on every
    -- play) go to the small corner view; errors from the browser (a typo in
    -- a pattern) still get a full notice
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      table.insert(opts.routes, {
        filter = { event = "msg_show", find = "^%[Strudel%] ", ["not"] = { find = "ERROR" } },
        view = "mini",
      })
      -- strudel.cc's scheduler complains once while the bridge silences its
      -- starter pattern, before anything was played: not an error of yours
      table.insert(opts.routes, { filter = { event = "msg_show", find = "no pattern set!" }, opts = { skip = true } })
    end,
  },
}
