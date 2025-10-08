return {
  cmd = { 'prisma-language-server', '--stdio' },
  filetypes = { 'prisma' },
  root_markers = { 'schema.prisma' },
  workspace_required = true,
  -- Optional: root_dir logic, if you want dynamic detection
  -- root_dir = function(fname)
  --   return vim.fs.dirname(vim.fs.find("schema.prisma", {
  --     upward = true,
  --     path = fname,
  --   })[1])
  -- end,
  settings = {
    prisma = {
      prismaFmtBinPath = '', -- leave empty unless you use a custom formatter path
    },
  },
}
