return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#1a1b26',
				base01 = '#1a1b26',
				base02 = '#7a7c83',
				base03 = '#7a7c83',
				base04 = '#babcc6',
				base05 = '#f8f9ff',
				base06 = '#f8f9ff',
				base07 = '#f8f9ff',
				base08 = '#ff9fb8',
				base09 = '#ff9fb8',
				base0A = '#a3abcf',
				base0B = '#93e2a0',
				base0C = '#e1e7ff',
				base0D = '#a3abcf',
				base0E = '#cad2f5',
				base0F = '#cad2f5',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#7a7c83',
				fg = '#f8f9ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#a3abcf',
				fg = '#1a1b26',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#7a7c83' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#e1e7ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#cad2f5',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#a3abcf',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#a3abcf',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#e1e7ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#93e2a0',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#babcc6' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#babcc6' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#7a7c83',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
