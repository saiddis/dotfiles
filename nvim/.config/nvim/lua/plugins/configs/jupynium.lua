local function expand(path)
	return vim.fn.expand(path)
end

local function first_existing(paths)
	for _, path in ipairs(paths) do
		local expanded = expand(path)
		if vim.uv.fs_stat(expanded) then
			return expanded
		end
	end
end

local python_host = expand("~/.local/share/mamba/envs/nvim/bin/python")
local jupyter_command = expand("~/.local/share/mamba/envs/nvim/bin/jupyter")

local M = {
	"kiyoon/jupynium.nvim",
	build = vim.fn.executable(python_host) == 1 and (python_host .. " -m pip install .") or "pip3 install --user .",
	dependencies = {
		"stevearc/dressing.nvim",
	},
	ft = { "markdown", "python", "quarto", "ipynb" },
	cmd = {
		"JupyniumStartAndAttachToServer",
		"JupyniumStartAndAttachToServerInTerminal",
		"JupyniumAttachToServer",
		"JupyniumStartSync",
		"JupyniumStopSync",
		"JupyniumLoadFromIpynbTab",
		"JupyniumLoadFromIpynbTabAndStartSync",
		"JupyniumSaveIpynb",
		"JupyniumDownloadIpynb",
		"JupyniumAutoDownloadIpynbToggle",
		"JupyniumExecuteSelectedCells",
		"JupyniumClearSelectedCellsOutputs",
		"JupyniumKernelRestart",
		"JupyniumKernelInterrupt",
		"JupyniumKernelSelect",
		"JupyniumKernelHover",
		"JupyniumKernelOpenInTerminal",
	},
	cond = not vim.g.started_by_firenvim and not vim.g.vscode,
}

function M.init()
	require("mappings").register({
		{ "<leader>j", group = "Jupynium" },
		{ "<leader>js", "<cmd>JupyniumStartAndAttachToServer<cr>", desc = "Start server + attach" },
		{ "<leader>jS", "<cmd>JupyniumStartAndAttachToServerInTerminal<cr>", desc = "Start server (terminal)" },
		{ "<leader>ja", "<cmd>JupyniumAttachToServer<cr>", desc = "Attach to server" },
		{ "<leader>jn", "<cmd>JupyniumStartSync<cr>", desc = "Start sync" },
		{ "<leader>jN", "<cmd>JupyniumStopSync<cr>", desc = "Stop sync" },
		{ "<leader>jx", "<cmd>JupyniumExecuteSelectedCells<cr>", desc = "Execute selected cells" },
		{ "<leader>jd", "<cmd>JupyniumDownloadIpynb<cr>", desc = "Download ipynb" },
		{ "<leader>jk", "<cmd>JupyniumKernelSelect<cr>", desc = "Select kernel" },
		{ "<leader>ji", "<cmd>JupyniumKernelInterrupt<cr>", desc = "Interrupt kernel" },
		{ "<leader>jr", "<cmd>JupyniumKernelRestart<cr>", desc = "Restart kernel" },
		{ "<leader>jt", "<cmd>JupyniumKernelOpenInTerminal<cr>", desc = "Open kernel terminal" },
		-- { "<leader>jk", "<cmd>JupyniumKernelHover<cr>", desc = "Jupinim inspect" },
	})
end

function M.config()
	require("jupynium").setup({
		python_host = vim.fn.executable(python_host) == 1 and python_host or (vim.g.python3_host_prog or "python3"),
		default_notebook_URL = "localhost:8888/nbclassic",
		jupyter_command = vim.fn.executable(jupyter_command) == 1 and jupyter_command or "jupyter",
		notebook_dir = nil,
		firefox_profiles_ini_path = first_existing({
			"~/.mozilla/firefox/profiles.ini",
			"~/snap/firefox/common/.mozilla/firefox/profiles.ini",
		}),
		firefox_profile_name = nil,
		auto_start_server = {
			enable = false,
			file_pattern = { "*.ju.*" },
		},
		auto_attach_to_server = {
			enable = true,
			file_pattern = { "*.ju.*" },
		},
		auto_start_sync = {
			enable = false,
			file_pattern = { "*.ju.*" },
		},
		auto_download_ipynb = false,
		auto_close_tab = true,
		autoscroll = {
			enable = true,
			mode = "always",
			focus = "input",
			cell = {
				top_margin_percent = 20,
			},
		},
		scroll = {
			page = { step = 0.5 },
			cell = {
				top_margin_percent = 20,
			},
		},
		jupynium_file_pattern = { "*.ju.*" },
		use_default_keybindings = false,
		textobjects = {
			use_default_keybindings = false,
		},
		syntax_highlight = {
			enable = true,
		},
		shortsighted = false,
		kernel_hover = {
			floating_win_opts = {
				max_width = 84,
				border = "solid",
			},
		},
		notify = {
			ignore = {},
		},
	})

	vim.api.nvim_set_hl(0, "JupyniumCodeCellSeparator", { link = "CursorLine" })
	vim.api.nvim_set_hl(0, "JupyniumMarkdownCellSeparator", { link = "CursorLine" })
	vim.api.nvim_set_hl(0, "JupyniumMarkdownCellContent", { link = "Normal" })
	vim.api.nvim_set_hl(0, "JupyniumMagicCommand", { link = "Keyword" })
end

return M
