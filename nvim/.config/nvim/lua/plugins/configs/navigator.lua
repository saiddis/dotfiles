local M = {
	"numToStr/Navigator.nvim",
	cmd = { "NavigatorLeft", "NavigatorRight", "NavigatorUp", "NavigatorDown" },
}

function M.init()
	vim.keymap.set({ "n", "t", "i" }, "<C-h>", "<CMD>NavigatorLeft<CR>")
	vim.keymap.set({ "n", "t", "i" }, "<C-l>", "<CMD>NavigatorRight<CR>")
	vim.keymap.set({ "n", "t", "i" }, "<C-k>", "<CMD>NavigatorUp<CR>")
	vim.keymap.set({ "n", "t", "i" }, "<C-j>", "<CMD>NavigatorDown<CR>")
end

function M.config()
	require("Navigator").setup()
end

return M
