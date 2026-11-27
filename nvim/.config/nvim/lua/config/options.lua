-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = true
vim.g.autoformat = false

-- Python: ty (type checker) + ruff, as in ~/dotfiles/legacy/nvim
vim.g.lazyvim_python_lsp = "ty"

-- Tabs drawn as blank space: the indent guides already mark them, and the
-- default "> " showed through in a split that hadn't been redrawn after a
-- resize. Trailing spaces and nbsp stay visible.
vim.opt.listchars = { tab = "  ", trail = "-", nbsp = "+" }
