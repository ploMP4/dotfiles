local present, null_ls = pcall(require, "null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatiing", {})

if not present then
  return
end

local b = null_ls.builtins
local h = require "null-ls.helpers"

local templ = {
  method = null_ls.methods.FORMATTING,
  filetypes = { "templ" },
  generator = h.formatter_factory {
    command = "templ",
    args = { "fmt", "$FILENAME" },
    to_temp_file = true,
  },
}

local gleam = {
  method = null_ls.methods.FORMATTING,
  filetypes = { "gleam" },
  generator = h.formatter_factory {
    command = "gleam",
    args = { "format", "$FILENAME" },
    to_temp_file = true,
  },
}

local sources = {
  templ,
  gleam,

  b.formatting.gofmt,
  b.formatting.goimports_reviser,
  b.formatting.golines,

  b.formatting.black,

  -- work related
  b.formatting.isort,
  b.diagnostics.flake8,

  b.formatting.clang_format,

  -- webdev stuff
  -- b.formatting.deno_fmt,
  b.formatting.prettier,

  -- Lua
  b.formatting.stylua,

  -- Shell
  -- b.formatting.shfmt,

  b.diagnostics.golangci_lint,
  b.diagnostics.eslint,
  -- b.diagnostics.mypy.with {
  --   extra_args = function()
  --     local virtual = os.getenv "VIRTUAL_ENV" or "/usr"
  --     return { "--python-executable", virtual .. "/bin/python3" }
  --   end,
  -- },
  b.diagnostics.ruff,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
}

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds {
        group = augroup,
        buffer = bufnr,
      }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })
    end
  end,
}
