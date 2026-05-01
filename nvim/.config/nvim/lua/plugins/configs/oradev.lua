local M = {
	"ShamatienkoYaroslav/oradev.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
		"nvim-neo-tree/neo-tree.nvim",
	},
	lazy = false,
	enabled = false,
	keys = {
		{ "<leader>oe", "<cmd>OraExplorer<cr>", desc = "Toggle Oracle Explorer" },
		{ "<leader>os", "<cmd>OraOpenSqlcl<cr>", desc = "Open SQLcl" },
		{ "<leader>on", "<cmd>OraWorksheetNew<cr>", desc = "New worksheet" },
		{ "<leader>ob", "<cmd>OraWorksheetRegister<cr>", desc = "Buffer to worksheet" },
		{ "<leader>or", "<cmd>OraWorksheetExecute<cr>", desc = "Run worksheet" },
		{ "<leader>oR", "<cmd>OraWorksheetExecuteSelected<cr>", desc = "Run selection", mode = "v" },
		{ "<leader>of", "<cmd>OraWorksheetFormat<cr>", desc = "Format worksheet" },
		{ "<leader>ox", "<cmd>OraWorksheetExplainPlan<cr>", desc = "Explain plan" },
		{ "<leader>oX", "<cmd>OraWorksheetExplainPlan<cr>", desc = "Explain selection", mode = "v" },
		{ "<leader>op", "<cmd>OraWorksheetExecutionPlan<cr>", desc = "Execution plan" },
		{ "<leader>oP", "<cmd>OraWorksheetExecutionPlan<cr>", desc = "Execution plan selection", mode = "v" },
		{ "<leader>oc", "<cmd>OraWorksheetChangeConnection<cr>", desc = "Change connection" },
		{ "<leader>oa", "<cmd>OraQuickAction<cr>", desc = "Quick action" },
	},
}

function M.config()
	require("ora").setup({
		sqlcl_path = "/opt/sqlcl/bin/sql",
	})

	-- Register the "ora" source with neo-tree (required for :OraExplorer)
	require("neo-tree").setup({
		sources = {
			"filesystem",
			"ora",
		},
	})
end

return M
