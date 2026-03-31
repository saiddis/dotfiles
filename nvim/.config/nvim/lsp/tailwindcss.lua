return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'javascript',
    'typescript',
    'svelte',
  },
  root_markers = { 'tailwind.config.js', 'package.json' },
}
