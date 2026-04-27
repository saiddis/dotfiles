local M = {
	"kylechui/nvim-surround",
	event = "VeryLazy",
	init = function()
		vim.g.nvim_surround_no_mappings = true
	end,
}

function M.config()
	require("nvim-surround").setup()

	vim.keymap.set("i", "<C-g>s", "<Plug>(nvim-surround-insert)")
	vim.keymap.set("i", "<C-g>S", "<Plug>(nvim-surround-insert-line)")
	vim.keymap.set("n", "s", "<Plug>(nvim-surround-normal)")
	vim.keymap.set("n", "ss", "<Plug>(nvim-surround-normal-cur)")
	vim.keymap.set("x", "s", "<Plug>(nvim-surround-visual)")
	vim.keymap.set("x", "gs", "<Plug>(nvim-surround-visual-line)")
	vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)")
	vim.keymap.set("n", "cs", "<Plug>(nvim-surround-change)")
end

return M
