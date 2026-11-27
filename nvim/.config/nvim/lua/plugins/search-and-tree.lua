-- Search and file-tree keybindings ported from ~/dotfiles/legacy/nvim, using the snacks.nvim already in this config.

local symbol_kinds = {
  "Class",
  "Constructor",
  "Enum",
  "Function",
  "Interface",
  "Method",
  "Module",
  "Namespace",
  "Package",
  "Property",
  "Struct",
  "Trait",
  "Variable",
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = true },
      picker = {
        win = {
          -- Only keys snacks leaves unused (<c-s>/<c-v> splits are already snacks defaults)
          input = {
            keys = {
              ["_"] = { "edit_split", mode = { "n" } },
              ["|"] = { "edit_vsplit", mode = { "n" } },
              ["<c-l>"] = { "loclist", mode = { "n", "i" } },
              ["<a-o>"] = { { "pick_win", "jump" }, mode = { "n", "i" } }, -- was <c-w>
            },
          },
          list = {
            keys = {
              ["_"] = "edit_split",
              ["|"] = "edit_vsplit",
              ["<c-l>"] = "loclist",
              ["<a-o>"] = { { "pick_win", "jump" } }, -- was <c-w>
            },
          },
        },
      },
    },
    -- Old binds on keys LazyVim/Omarchy don't use. Clashing ones moved (old key in comment).
    keys = {
      { "<leader>fs", function() Snacks.picker.explorer() end, desc = "Explorer Snacks (tree)" }, -- was <leader>e
      { "<leader>sf", function() Snacks.picker.files() end, desc = "Find files" }, -- was fff.nvim in the old config
      {
        "<leader>sy",
        function()
          Snacks.picker.lsp_symbols({ layout = "left", filter = { default = symbol_kinds } })
        end,
        desc = "Symbols (sidebar)",
      }, -- was <leader>sc
      { "<leader>sY", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Symbols (workspace)" }, -- was <leader>sw
      { "<leader>sL", function() Snacks.picker.lsp_config() end, desc = "LSP servers" }, -- was <leader>sl
      { "<leader>sP", function() Snacks.picker.projects() end, desc = "Projects" }, -- was <leader>sp
      { "<leader>so", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      -- <leader>sb (buffers) -> LazyVim's <leader>,  |  <leader>sg (cwd grep) -> LazyVim's <leader>sG
    },
  },
}
