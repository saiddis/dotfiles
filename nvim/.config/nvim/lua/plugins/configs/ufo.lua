local M = {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	event = "VeryLazy",
	enabled = true,
}

local handler = function(virtText, lnum, endLnum, width, truncate)
	local icons = require("icons")

	local newVirtText = {}
	local suffix = (" " .. icons.arrow.down_left .. " %d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			-- str width returned from truncate() may less than 2nd argument, need padding
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, "MoreMsg" })
	return newVirtText
end

function M.init()
	-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
	vim.keymap.set("n", "zR", require("ufo").openAllFolds)
	vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
end

function M.config()
	local ufo = require("ufo")
	vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
	vim.o.foldcolumn = "1" -- '0' is not bad
	vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
	vim.o.foldlevelstart = 99
	vim.o.foldenable = true

	local function get_cell_folds(bufnr)
		local function handleFallbackException(err, providerName)
			if type(err) == "string" and err:match("UfoFallbackException") then
				return ufo.getFolds(bufnr, providerName)
			else
				return require("promise").reject(err)
			end
		end
		return ufo.getFolds(bufnr, "lsp")
			:catch(function(err)
				return handleFallbackException(err, "treesitter")
			end)
			:catch(function(err)
				return handleFallbackException(err, "indent")
			end)
			:thenCall(function(ufo_folds)
				local ok, jupynium = pcall(require, "jupynium")
				if ok then
					for _, fold in ipairs(jupynium.get_folds()) do
						table.insert(ufo_folds, fold)
					end
				end
				return ufo_folds
			end)
	end

	local ftMap = {
		python = get_cell_folds,
	}

	ufo.setup({
		provider_selector = function(bufnr, filetype, buftype)
			return ftMap[filetype]
		end,
	})
end

return M
