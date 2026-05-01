local M = {
	"leoluz/nvim-dap-go",
	enabled = false,
	cond = not vim.g.started_by_firenvim and not vim.g.vscode,
}

function M.config()
	require("dap-go").setup()
end

return M
