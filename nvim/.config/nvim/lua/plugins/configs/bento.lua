local M = {
	"serhez/bento.nvim",
	dev = false,
	cond = not vim.g.started_by_firenvim,
	event = "VeryLazy",
}

function M.config()
	require("bento").setup({
		main_keymap = "<C-;>",
		max_open_buffers = 10,
		map_last_accessed = false,
		default_action = "open",
		actions = {
			open = {
				key = "<CR>",
				hl = "DiagnosticVirtualTextHint",
			},
			delete = {
				key = "<BS>",
				hl = "DiagnosticVirtualTextError",
			},
			vsplit = {
				key = "|",
				hl = "DiagnosticVirtualTextInfo",
			},
			split = {
				key = "_",
				hl = "DiagnosticVirtualTextInfo",
			},
			lock = {
				key = "*",
				hl = "DiagnosticVirtualTextWarn",
			},
		},
	})
end

return M
