local M = {}

function M.setup()
	vim.opt.guifont = "JetBrainsMono Nerd Font:h11:#h-none:#e-subpixelantialias"
	vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver20"
	vim.g.neovide_padding_top = 5
	vim.g.neovide_padding_bottom = 10
	vim.g.neovide_padding_right = 20
	vim.g.neovide_padding_left = 20
	vim.g.neovide_cursor_animation_length = 0.1
	vim.g.neovide_cursor_trail_size = 0.2
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0
	vim.g.neovide_text_gamma = 0.0
	vim.g.neovide_text_contrast = 1
	vim.g.neovide_floating_corner_radius = 2
	vim.g.neovide_progress_bar_enabled = true
	vim.g.neovide_progress_bar_height = 5.0
	vim.g.neovide_progress_bar_animation_speed = 200.0
	vim.g.neovide_progress_bar_hide_delay = 0.2
	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_fullscreen = false
	vim.g.neovide_cursor_animate_in_insert_mode = true
	vim.g.neovide_refresh_rate = 60
end

return M
