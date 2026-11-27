-- Language support not covered by LazyVim's lang extras (see lazyvim.json).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
        -- taplo only finds a root through .taplo.toml / taplo.toml / .git, and
        -- with no root it flags every other TOML file (herdr's config, the
        -- Omarchy theme) "this document has been excluded" on line 1. The
        -- file's own directory is a fine root for a lone config file.
        taplo = {
          root_dir = function(bufnr, on_dir)
            local markers = { ".taplo.toml", "taplo.toml", ".git" }
            on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
          end,
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "shellcheck" } },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "css", "sql", "make", "gitignore", "dockerfile", "svelte", "go", "gomod", "gosum", "gowork" },
    },
  },
}
