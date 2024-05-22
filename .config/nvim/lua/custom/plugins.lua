local plugins = {
  {
    "folke/todo-comments.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "VeryLazy",
    config = function()
      local harpoon = require "harpoon"
      harpoon:setup()
    end,
  },
  {
    "mbbill/undotree",
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      treesitter_parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "master",
        },
      }

      vim.treesitter.language.register("templ", "templ")

      return require "plugins.configs.treesitter"
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme "tokyonight-night"
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    after = "nvim-lspconfig",
    config = function()
      require "custom.configs.null-ls"
    end,
    lazy = false,
  },
  {
    "MunifTanjim/prettier.nvim",
    lazy = false,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "tsx",
      "jsx",
      "php",
      "svelte",
      "vue",
      "templ",
      "htmldjango",
    },
  },
  {
    "romgrk/nvim-treesitter-context",
    lazy = false,
    config = function()
      require("treesitter-context").setup {
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {
          -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the 'default' entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
            "class",
            "function",
            "method",
          },
        },
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",

        "pyright",
        "mypy",
        "ruff",
        "black",
        "debugpy",

        "goimports-reviser",
        "golines",
        "gopls",
        "golangci-lint",
        "templ",

        "delve",

        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "eslint-lsp",
        "typescript-language-server",
        "prettier",

        "clangd",
        "clang-format",
        "codelldb",
        "cmake-language-server",

        "lua-language-server",
        "stylua",

        "yaml-language-server",
        "bash-language-server",
        "marksman",
        "jdtls",
        "json-lsp",
        "shellcheck",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("core.utils").load_mappings "dap"
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
      require("core.utils").load_mappings "dap_python"
    end,
  },
  { "nvim-neotest/nvim-nio" },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
    },
  },
  -- go
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
      require("core.utils").load_mappings "gopher"
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  {
    "vrischmann/tree-sitter-templ",
    after = "nvim-treesitter/nvim-treesitter",
    ft = "templ",
  },
  -- rust
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    after = "neovim/nvim-lspconfig",
    opts = function()
      return require "custom.configs.rust-tools"
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      crates.show()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    ft = { "rust", "toml" },
    opts = function()
      local M = require "plugins.configs.cmp"
      table.insert(M.sources, { name = "crates" })
    end,
  },
}

return plugins
