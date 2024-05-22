local M = {}

M.general = {
  i = {
    ["<C-c>"] = { "<Esc>", "" },
  },

  -- x = {
  --   ["<leader>P"] = { [["_dP]], "" },
  -- },

  n = {
    ["<C-d>"] = { "<C-d>zz", "Center screen after jumping down" },
    ["<C-u>"] = { "<C-u>zz", "Center screen after jumping up" },

    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },

    -- ["<leader>y"] = { '[["+y]]', "" },
    -- ["<leader>Y"] = { '[["+Y]]', "" },
  },

  v = {
    ["J"] = { ":m '>+1<CR>gv=gv", "Move selected lines down" },
    ["K"] = { ":m '<-2<CR>gv=gv", "Move selected lines up" },

    ["<leader>y"] = { '[["+y]]', "copy whole funciton to clipboard" },
  },

  t = {
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },
  },
}

M.tabufline = {
  plugin = true,

  n = {
    -- cycle through buffers
    ["<S-l>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "goto next buffer",
    },

    ["<S-h>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "goto prev buffer",
    },

    -- close buffer + hide terminal buffer
    ["<leader>c"] = {
      function()
        require("nvchad.tabufline").close_buffer()
      end,
      "close buffer",
    },
  },
}

M.lspconfig = {
  plugin = true,

  n = {
    ["<leader>ld"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "lsp definition type",
    },

    ["<leader>lr"] = {
      function()
        require("nvchad.renamer").open()
      end,
      "lsp rename",
    },

    ["<leader>la"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "lsp code_action",
    },

    ["<leader>lk"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      "Prev Diagnostic",
    },

    ["<leader>lj"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      "Next Diagnostic",
    },

    ["<leader>lf"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "lsp formatting",
    },
  },
}

M.nvimtree = {
  plugin = true,

  n = {
    -- toggle
    ["<leader>e"] = { "<cmd> NvimTreeToggle <CR>", "toggle nvimtree" },

    -- focus
    ["<C-n>"] = { "<cmd> NvimTreeFocus <CR>", "focus nvimtree" },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- find
    ["<leader>ff"] = { "<cmd> Telescope git_files <CR>", "find files" },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "find all" },
    ["<leader>fg"] = { "<cmd> Telescope live_grep <CR>", "live grep" },

    ["<leader>lw"] = { "<cmd> Telescope diagnostics <CR>", "diagnostics" },

    -- git
    ["<leader>gc"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
    ["<leader>gs"] = { "<cmd> Telescope git_status <CR>", "Git status" },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint",
    },

    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },

    ["<leader>dus"] = {
      function()
        local widgets = require "dap.ui.widgets"
        local sidebar = widgets.sidebar(widgets.scopes)
        sidebar.open()
      end,
      "Open debugging sidebar",
    },
  },
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require("dap-python").test_method()
      end,
    },
  },
}

M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags",
    },
    ["<leader>gsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
      "Add yaml struct tags",
    },
  },
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["<leader>ghn"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },
    ["<leader>ghb"] = {
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to prev hunk",
      opts = { expr = true },
    },

    -- Actions
    ["<leader>ghp"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview hunk",
    },
    ["<leader>ghr"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },
    ["<leader>ghs"] = {
      function()
        require("gitsigns").stage_hunk()
      end,
      "Stage hunk",
    },
    ["<leader>gb"] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      "Blame line",
    },
    ["<leader>gtd"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle deleted",
    },
    ["<leader>gd"] = {
      function()
        require("gitsigns").diffthis()
      end,
      "Git Diff",
    },
  },
}

M.harpoon = {
  n = {
    ["<leader>ha"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():append()
      end,
      "Harpoon Add file",
    },
    ["<leader>ht"] = { "<CMD>Telescope harpoon marks<CR>", "Toggle quick menu" },
    ["<leader>hm"] = {
      function()
        local harpoon = require "harpoon"
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      "Harpoon Menu",
    },
    ["<leader>hh"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(1)
      end,
      "Navigate to file 1",
    },
    ["<leader>hj"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(2)
      end,
      "Navigate to file 2",
    },
    ["<leader>hk"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(3)
      end,
      "Navigate to file 3",
    },
    ["<leader>hl"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(4)
      end,
      "Navigate to file 4",
    },
  },
}

return M
