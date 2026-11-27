local M = {
	"christoomey/vim-tmux-navigator",
	enabled = false,
	lazy = false,
	init = function()
		vim.g.tmux_navigator_no_mappings = 1
	end,
	config = function()
		dofile(vim.fn.expand("/home/saiddis/vim-herdr-navigation/editor/nvim.lua"))
	end,
}

return M
