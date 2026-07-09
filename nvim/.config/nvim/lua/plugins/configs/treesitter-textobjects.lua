local M = {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
}

function M.config()
	require("nvim-treesitter-textobjects").setup({
		select = {
			lookahead = true, -- automatically jump forward to textobj, similar to targets.vim
		},
		move = {
			set_jumps = true, -- whether to set jumps in the jumplist
		},
	})

	local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

	-- Repeat movement with ; and ,
	-- ensure ; goes forward and , goes backward regardless of the last direction
	vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
	vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

	-- vim way: ; goes to the direction you were moving.
	-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
	-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

	-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
	vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

	-- SECTION: Keymaps

	-- You can use the capture groups defined in `textobjects.scm`
	require("mappings").register({
		-- Select
		{
			"af",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Around function",
		},
		{
			"if",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Inside function",
		},
		{
			"ac",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Around class",
		},
		{
			"ic",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Inside class",
		},
		{
			"ap",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Around parameter",
		},
		{
			"ip",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Inside parameter",
		},
		{
			"ab",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@block.outer", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Around block",
		},
		{
			"ib",
			function()
				require("nvim-treesitter-textobjects.select").select_textobject("@block.inner", "textobjects")
			end,
			mode = { "x", "o" },
			desc = "Inside block",
		},

		-- FIX: not working
		-- Swap
		{
			"Sl",
			function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end,
			mode = "n",
			desc = "Swap with next",
		},
		{
			"Sh",
			function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end,
			mode = "n",
			desc = "Swap with previous",
		},

		-- Move
		{
			"]c",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@class.inner", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Next class start",
		},
		{
			"]p",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Next parameter start",
		},
		{
			"]]",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@function.inner", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Next function start",
		},
		{
			"]C",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Next class end",
		},
		{
			"]P",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@parameter.outer", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Next parameter end",
		},
		{
			"][",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Next function end",
		},
		{
			"[c",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@class.inner", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous class start",
		},
		{
			"[p",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous parameter start",
		},
		{
			"[[",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@function.inner", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous function start",
		},
		{
			"[C",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous class end",
		},
		{
			"[P",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@parameter.outer", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous parameter end",
		},
		{
			"[]",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous function end",
		},
		{
			"]o",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_start(
					{ "@loop.inner", "@loop.outer" },
					"textobjects"
				)
			end,
			mode = { "n", "x", "o" },
			desc = "Next loop start",
		},
		{
			"]z",
			function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
			end,
			mode = { "n", "x", "o" },
			desc = "Next fold start",
		},
		{
			"[o",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_start(
					{ "@loop.inner", "@loop.outer" },
					"textobjects"
				)
			end,
			mode = { "n", "x", "o" },
			desc = "Previous loop start",
		},
		{
			"[z",
			function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@fold", "folds")
			end,
			mode = { "n", "x", "o" },
			desc = "Previous fold start",
		},
	})
end

return M
