local M = {
	"lukas-reineke/indent-blankline.nvim",
	lazy = false,
	enabled = false,
	main = "ibl",
	---@module "ibl"
	---@type ibl.config
	opts = {},
}

function M.config()
	require("ibl").setup()
end

return M
