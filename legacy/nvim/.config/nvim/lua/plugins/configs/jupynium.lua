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
	enabled = true,
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
		{ "<leader>n", group = "Notebook" },
		{ "<leader>ns", "<cmd>JupyniumStartAndAttachToServer<cr>", desc = "Start server + attach" },
		{ "<leader>nS", "<cmd>JupyniumStartAndAttachToServerInTerminal<cr>", desc = "Start server (terminal)" },
		{ "<leader>na", "<cmd>JupyniumAttachToServer<cr>", desc = "Attach to server" },
		{ "<leader>nn", "<cmd>JupyniumStartSync<cr>", desc = "Start sync" },
		{ "<leader>nN", "<cmd>JupyniumStopSync<cr>", desc = "Stop sync" },
		{ "<leader>nx", "<cmd>JupyniumExecuteSelectedCells<cr>", desc = "Execute selected cells" },
		{ "<leader>nd", "<cmd>JupyniumDownloadIpynb<cr>", desc = "Download ipynb" },
		{ "<leader>nk", "<cmd>JupyniumKernelSelect<cr>", desc = "Select kernel" },
		{ "<leader>ni", "<cmd>JupyniumKernelInterrupt<cr>", desc = "Interrupt kernel" },
		{ "<leader>nr", "<cmd>JupyniumKernelRestart<cr>", desc = "Restart kernel" },
		{ "<leader>nt", "<cmd>JupyniumKernelOpenInTerminal<cr>", desc = "Open kernel terminal" },
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

	-- Cell-by-cell navigation (jupynium files only).
	-- The plugin's textobj module already integrates with
	-- nvim-treesitter-textobjects, so `;` / `,` repeat the last cell jump.
	local augroup = vim.api.nvim_create_augroup("JupyniumCellMotions", { clear = true })
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = augroup,
		pattern = require("jupynium.options").opts.jupynium_file_pattern,
		callback = function(event)
			local textobj = require("jupynium.textobj")
			vim.keymap.set(
				{ "n", "x", "o" },
				"<C-n>",
				textobj.goto_next_cell_separator,
				{ buffer = event.buf, desc = "Next Jupynium cell" }
			)
			vim.keymap.set(
				{ "n", "x", "o" },
				"<C-p>",
				textobj.goto_previous_cell_separator,
				{ buffer = event.buf, desc = "Previous Jupynium cell" }
			)
		end,
	})
end

return M
