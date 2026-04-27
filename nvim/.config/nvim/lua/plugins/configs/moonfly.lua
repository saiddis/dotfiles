local M = {
	"bluz71/vim-moonfly-colors",
	name = "moonfly",
	lazy = false,
	priority = 1000,
}

local function apply_override_colors(colors)
	local ui = {
		bg_primary = colors.bg,
		fg_primary = colors.white,

		bg_secondary = colors.grey7,
		fg_secondary = colors.mineral,

		bg_highlight = colors.mineral,
		fg_highlight = colors.blue,

		bg_border = colors.grey7,
		fg_border = colors.grey7,

		selected = colors.grey15,
		dim = colors.grey7,
	}

	local override_colors = {
		NormalFloat = { bg = ui.bg_secondary, fg = ui.fg_primary },
		FloatBorder = { bg = ui.bg_border, fg = ui.fg_border },
		FloatTitle = { bg = ui.bg_highlight, fg = ui.fg_highlight, bold = true },
		SnacksPickerGitStatusModified = { fg = colors.orange },
		SnacksPickerGitStatusChanged = { fg = colors.yellow },
		TroubleIndent = { bg = ui.bg_secondary, fg = ui.fg_secondary },
		TroubleCount = { bg = ui.bg_highlight, fg = ui.fg_highlight, bold = true },
		TroublePos = { bg = ui.bg_secondary, fg = ui.fg_secondary },
		VertSplit = { bg = ui.bg_border, fg = ui.fg_border },
		ColorfulWinSep = { bg = ui.bg_secondary, fg = ui.fg_highlight },
		CursorLineNr = { bg = ui.selected, fg = ui.fg_highlight, bold = true },
		CursorLine = { bg = ui.selected, bold = false },
		CursorLineSign = { bg = ui.selected },
		LineNr = { bg = ui.bg_primary, fg = ui.fg_secondary },
		SignColumn = { bg = ui.bg_primary },
		FoldColumn = { bg = ui.bg_primary, fg = ui.fg_secondary },
		CursorLineFold = { bg = ui.selected },
	}

	for highlight, value in pairs(override_colors) do
		vim.api.nvim_set_hl(0, highlight, value)
	end
end

function M.config()
	vim.g.moonflyNormalFloat = false
	vim.g.moonflyTransparent = false
	vim.g.moonflyUndercurls = true
	vim.g.moonflyWinSeparator = 0
	vim.g.moonflyUnderlineMatchParen = true
	vim.g.moonflyItalics = true
	vim.g.nightflyCursorColor = true

	local diagnostic_config = vim.diagnostic.config() or {}
	diagnostic_config.float = vim.tbl_deep_extend("force", diagnostic_config.float or {}, {
		border = "single",
	})
	vim.diagnostic.config(diagnostic_config)

	vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
		config = vim.tbl_deep_extend("force", config or {}, { border = "single" })
		return vim.lsp.handlers.hover(err, result, ctx, config)
	end
	vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
		config = vim.tbl_deep_extend("force", config or {}, { border = "single" })
		return vim.lsp.handlers.signature_help(err, result, ctx, config)
	end

	local colors = require("moonfly").palette

	colors.bg = "#000000"
	colors.white = "#D7D7D7"
	colors.green = "#B1E268"
	colors.lime = "#25FF5F"
	colors.emerald = "#38dc90"
	colors.turquoise = "#7fdbca"
	colors.khaki = "#E3CF65"
	colors.yellow = "#E6E666"
	colors.orange = "#FC9949"
	colors.blue = "#5588FF"
	colors.sky = "#5CCEFF"
	colors.purple = "#AE81FF"
	colors.violet = "#E593EE"
	colors.lavender = "#a9b1d6"
	-- colors.orchid = "#ff79c6"

	require("moonfly").custom_colors(colors)

	-- vim.cmd.colorscheme("moonfly")
	-- apply_override_colors(colors)

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("moonfly_custom_highlights", { clear = true }),
		pattern = "moonfly",
		callback = function()
			apply_override_colors(colors)
		end,
	})

	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("moonfly_custom_highlights_startup", { clear = true }),
		callback = function()
			apply_override_colors(colors)
		end,
	})
end

return M
