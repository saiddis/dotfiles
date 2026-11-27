-- LazyVim's statusline echoes the last keys typed (noice's showcmd status):
-- "gj" after every j, and a stuck "^[" after herdr-splits forwards Alt+hjkl
-- to resize a split. It never clears, so it is noise. Pending keys still show
-- in which-key.
return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.status = opts.status or {}
      opts.status.command = false
    end,
  },
}
