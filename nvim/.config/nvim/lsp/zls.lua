return {
  cmd = { 'zls' },
  filetypes = { 'zig' },
  root_markers = {
    'build.zig',
    'build.zig.zon',
    '.git',
  },
  settings = {
    zls = {
      -- Enable semantic tokens (better highlighting)
      enable_semantic_tokens = true,

      -- Automatically discover zig executable
      zig_exe_path = 'zig',

      -- Control build-on-save behavior
      build_on_save = false,

      -- Where ZLS stores global cache
      global_cache_path = vim.fn.stdpath 'cache' .. '/zls',

      -- Formatting
      enable_autofix = true,
    },
  },
}
