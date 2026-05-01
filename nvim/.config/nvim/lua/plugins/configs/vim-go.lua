local M = {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		-- { "nvim-treesitter/nvim-treesitter", branch = 'main' } -- optional for master version
	},

	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()',
}

M.config = function()
	require("go").setup(opts)
	local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*.go",
		callback = function()
			require("go.format").goimports()
		end,
		group = format_sync_grp,
	})
	return {
		lsp_cfg = true,
		-- lsp_keymaps = false,
		-- other options
	}
end

return M
