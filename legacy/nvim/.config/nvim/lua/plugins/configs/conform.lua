local M = {
	"stevearc/conform.nvim",
	event = "VeryLazy",
}

function M.init()
	local formatting = require("plugins.configs.mason-lspconfig.formatting")

	require("mappings").register({
		{
			"<leader>f",
			function()
				formatting.format(vim.api.nvim_get_current_buf())
			end,
			desc = "Format buffer",
		},
		{
			"<leader>F",
			function()
				local enabled = formatting.toggle_auto_format()
				vim.notify(
					(enabled and "Enabled" or "Disabled") .. " auto-formatting",
					vim.log.levels.INFO,
					{ title = "Auto-formatting" }
				)
			end,
			desc = "Toggle auto-format",
		},
	})
end

function M.config()
	require("conform").setup({
		default_format_opts = {
			timeout_ms = 2000,
			async = false,
			quiet = false,
		},

		formatters_by_ft = {
			go = { "goimports" },
			sh = { "shfmt" },
			lua = { "stylua" },
			python = { "ruff_fix", "ruff_format" },

			c = { "clang_format" },
			cpp = { "clang_format" },

			-- javascript = { "prettierd" },
			-- typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			["javascript.jsx"] = { "prettierd" },
			typescriptreact = { "prettierd" },
			["typescript.tsx"] = { "prettierd" },
			svelte = { "prettierd" },

			html = { "prettierd" },
			css = { "prettierd" },
			markdown = { "cbfmt" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			toml = { "taplo" },
			make = { "cmake_format" },
			cmake = { "cmake_format" },
			sql = { "sleek" },

			["*"] = { "injected" },
		},

		formatters = {
			injected = {
				options = {
					ignore_errors = false,
				},
			},
			prettierd = {
				env = {
					PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/.prettierrc"),
				},
			},
		},
	})

	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

	-- Auto-format on save
	local formatting = require("plugins.configs.mason-lspconfig.formatting")
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		group = formatting.augroup,
		callback = function(args)
			formatting.auto_format(args.buf)
		end,
	})
end

return M
