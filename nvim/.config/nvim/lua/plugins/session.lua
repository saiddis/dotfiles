-- Sessions from the old config (~/dotfiles/legacy/nvim, auto-session.lua): quitting
-- saves the session and starting `nvim` with no file restores it (buffers,
-- splits, cursor), per directory and git branch. LazyVim's own
-- persistence.nvim (restore by hand) is off so there is one session system.

-- The old config told sessions apart per tmux session:window. herdr is the
-- multiplexer now, so the tag is herdr workspace:tab ("hypr:1"); two Neovims
-- in one directory in different herdr tabs keep separate sessions. An unnamed
-- tab's label is its number, so closing or moving tabs can shift which
-- session a tab gets (as tmux window indexes did); naming the tab
-- (prefix + shift + t) keeps it fixed.
-- Returns "" outside herdr, nil when herdr can't be asked (its server
-- shutting down, say).
local function herdr_tag()
  if vim.env.HERDR_ENV ~= "1" or not vim.env.HERDR_WORKSPACE_ID then
    return ""
  end
  local function label(args, list, id_key, id)
    local ok, res = pcall(function()
      return vim.system(vim.list_extend({ "herdr" }, args), { text = true, timeout = 1000 }):wait()
    end)
    if not ok or res.code ~= 0 then
      return nil
    end
    local decoded_ok, decoded = pcall(vim.json.decode, res.stdout, { luanil = { object = true, array = true } })
    for _, item in ipairs((decoded_ok and decoded and decoded.result and decoded.result[list]) or {}) do
      if item[id_key] == id then
        return item.label
      end
    end
  end
  local ws = label({ "workspace", "list" }, "workspaces", "workspace_id", vim.env.HERDR_WORKSPACE_ID)
  local tab = ws
    and vim.env.HERDR_TAB_ID
    and label({ "tab", "list", "--workspace", vim.env.HERDR_WORKSPACE_ID }, "tabs", "tab_id", vim.env.HERDR_TAB_ID)
  return tab and (ws .. ":" .. tab) or nil
end

return {
  { "folke/persistence.nvim", enabled = false },
  {
    -- A restore by hand (<leader>qs) would also bring auto-session's own
    -- "Restored session: <path>" next to the one from post_restore_cmds
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      table.insert(opts.routes, { filter = { event = "notify", find = "^Restored session: " }, opts = { skip = true } })
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    -- LazyVim's session keys (persistence.nvim's) on auto-session
    keys = {
      { "<leader>qs", "<cmd>AutoSession restore<cr>", desc = "Restore Session" },
      { "<leader>qS", "<cmd>AutoSession search<cr>", desc = "Select Session" },
      { "<leader>qd", "<cmd>AutoSession disable<cr>", desc = "Don't Save Current Session" },
    },
    init = function()
      -- What a session keeps (old config, settings.lua)
      vim.o.sessionoptions = "globals,blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
    opts = function()
      -- Looked up at startup and again at each save (a renamed tab moves its
      -- session along). When herdr stops with Neovim still open the save-time
      -- lookup fails, so the startup tag is used; if even that failed,
      -- sessions are left alone rather than all landing on one shared name.
      local tag = herdr_tag()
      return {
        auto_save = tag ~= nil,
        auto_restore = tag ~= nil,
        git_use_branch_name = true, -- one session per git branch
        git_auto_restore_on_branch_change = true,
        -- "Restored session" when one comes back, nothing when the
        -- directory has none yet (auto-session's own notice also says
        -- "Could not restore session" every time that happens)
        show_auto_restore_notif = false,
        post_restore_cmds = {
          function()
            vim.notify("Restored session", vim.log.levels.INFO, { title = "Session" })
          end,
        },
        cwd_change_handling = true, -- save before a :cd, restore after
        log_level = "info",
        -- File trees and pickers would come back as empty windows: close them
        -- before saving. Quitting from the start dashboard alone keeps the
        -- session that was there.
        close_filetypes_on_save = {
          "checkhealth", "neo-tree", "snacks_layout_box", "snacks_picker_list",
          "snacks_picker_input", "snacks_picker_preview",
        },
        bypass_save_filetypes = { "snacks_dashboard" },
        -- `nvim file` / `nvim -O a b` save too, so the next bare `nvim`
        -- comes back to them, but only when every file belongs to this
        -- directory: a git commit message, a temp file another tool hands
        -- to $EDITOR, or `nvim /etc/hosts` leaves the project's session alone.
        args_allow_files_auto_save = function()
          local root = vim.fn.getcwd() .. "/"
          for _, arg in ipairs(vim.fn.argv()) do
            local path = vim.fn.fnamemodify(arg, ":p")
            if path:sub(1, #root) ~= root or path:find("/%.git/") then
              return false
            end
          end
          return true
        end,
        custom_session_tag = function()
          tag = herdr_tag() or tag
          return tag or ""
        end,
      }
    end,
  },
}
