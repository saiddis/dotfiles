local M = {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	enabled = false,
}

function M.config()
	require("supermaven-nvim").setup({
		keymaps = {
			accept_suggestion = "<C-l>",
			clear_suggestion = "<C-h>",
			accept_word = "<C-w>",
		},
	})
end

return M
