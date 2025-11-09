return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    explorer = { enabled = true, replace_netrw = true },
    indent = { enabled = true },
    input = { enabled = true },
    notify = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 2000,
      width = { min = 40, max = 1000 },
      height = { min = 1, max = 1000 },
    },
    bufdelete = { enabled = true },
    dashboard = { enabled = true },
    scope = { enabled = true },
    gh = { enabled = false },
    keymap = { enabled = true },
    image = { enabled = true },
    picker = {
      sources = {
        matcher = {
          frecency = true,
        },
        select = {
          layout = {
            preset = 'telescope-custom',
          },
        },
      },
      ui_select = true,
      enabled = true,
      prompt = '  ',
      layout = {
        preset = 'telescope-custom',
      },
      layouts = {
        ['telescope-custom-select'] = {
          reverse = false,
          layout = {
            box = 'horizontal',
            backdrop = false,
            width = 0.5,
            height = 2,
            border = 'none',
            {
              box = 'vertical',
              { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'center' },
              {
                win = 'list',
                title = ' Results ',
                title_pos = 'center',
                border = 'rounded',
                height = 30,
              },
            },
          },
        },
        ['telescope-custom'] = {
          reverse = false,
          layout = {
            box = 'horizontal',
            backdrop = false,
            width = 0.8,
            height = 0.9,
            border = 'none',
            {
              box = 'vertical',
              { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'center' },
              { win = 'list', title = '', title_pos = 'center', border = 'rounded' },
            },
            {
              win = 'preview',
              title = '{preview:Preview}',
              width = 0.53,
              border = 'rounded',
              title_pos = 'center',
            },
          },
        },
      },
    },
    lazygit = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    layout = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
    -- animate = { enabled = true },
  },
  keys = {
    {
      '<leader><space>',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<C-y>',
      function()
        Snacks.explorer()
      end,
      desc = 'File Explorer',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files {
          layout = 'vscode',
        }
      end,
      desc = 'Find Files',
    },
    {
      '<leader>sl',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>sB',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = 'Grep Open Buffers',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.projects()
      end,
      desc = 'Projects',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.commands()
      end,
      desc = 'Commands',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics {
          layout = 'bottom',
          matcher = {
            fuzzy = true,
            ignorecase = false,
            smartcase = true,
          },
        }
      end,
      desc = 'Diagnostics',
    },
    {
      '<leader>sD',
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = 'Buffer Diagnostics',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = 'Help Pages',
    },
    {
      '<leader>sH',
      function()
        Snacks.picker.highlights()
      end,
      desc = 'Highlights',
    },
    {
      '<leader>sj',
      function()
        Snacks.picker.jumps()
      end,
      desc = 'Jumps',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = 'Keymaps',
    },
    {
      '<leader>sM',
      function()
        Snacks.picker.man()
      end,
      desc = 'Man Pages',
    },
    {
      '<leader>sq',
      function()
        Snacks.picker.qflist()
      end,
      desc = 'Quickfix List',
    },
    {
      '<leader>sR',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.undo()
      end,
      desc = 'Undo History',
    },
    {
      '<leader>co',
      function()
        Snacks.picker.colorschemes()
      end,
      desc = 'Colorschemes',
    },
    -- LSP
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = 'Goto Definition',
    },
    {
      'gD',
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = 'Goto Declaration',
    },
    {
      'gr',
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = 'References',
    },
    {
      'gi',
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = 'Goto Implementation',
    },
    {
      'gy',
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = 'Goto T[y]pe Definition',
    },
    -- {
    -- 	"<leader>ss",
    -- 	function()
    -- 		Snacks.picker.lsp_symbols({
    -- 			layout = "left",
    -- 			filter = {
    -- 				default = {
    -- 					"Class",
    -- 					"Constructor",
    -- 					"Enum",
    -- 					-- "Field",
    -- 					"Function",
    -- 					"Interface",
    -- 					"Method",
    -- 					"Module",
    -- 					"Namespace",
    -- 					"Package",
    -- 					"Property",
    -- 					"Struct",
    -- 					"Trait",
    -- 					"Variable",
    -- 				},
    -- 			},
    -- 		})
    -- 	end,
    -- 	desc = "LSP Symbols",
    -- },
    {
      '<leader>sw',
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = 'LSP Workspace Symbols',
    },
    {
      '<leader>ca',
      function()
        vim.lsp.buf.code_action()
      end,
      desc = 'Code actions',
    },
    {
      '<leader>rn',
      function()
        vim.lsp.buf.rename()
      end,
      desc = 'Rename symbols',
    },
    -- Other
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle Zen Mode',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Toggle Zoom',
    },
    -- {
    --   '<leader>.',
    --   function()
    --     Snacks.scratch()
    --   end,
    --   desc = 'Toggle Scratch Buffer',
    -- },
    -- {
    --   '<leader>S',
    --   function()
    --     Snacks.scratch.select()
    --   end,
    --   desc = 'Select Scratch Buffer',
    -- },
    {
      '<leader>mv',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Move File',
    },
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<c-_>',
      function()
        Snacks.terminal()
      end,
      desc = 'which_key_ignore',
    },
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = { 'n', 't' },
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = { 'n', 't' },
    },
    {
      '<leader>N',
      desc = 'Neovim News',
      function()
        Snacks.win {
          file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = 'yes',
            statuscolumn = ' ',
            conceallevel = 3,
          },
        }
      end,
    },
  },
}
