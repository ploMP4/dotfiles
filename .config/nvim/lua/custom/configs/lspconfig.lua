local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
    },
  },
}

lspconfig.cmake.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

lspconfig.templ.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "templ", "lsp" },
  filetypes = { "templ" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
}

lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
  },
}

lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "templ", "htmldjango" },
  init_options = {
    userLanguages = {
      templ = "html",
      htmldjango = "html",
    },
  },
}

lspconfig.htmx.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "templ", "htmldjango" },
  init_options = {
    userLanguages = {
      templ = "html",
      htmldjango = "html",
    },
  },
}

-- lspconfig.cssls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "jsx", "html", "tsx", "templ", "htmldjango" },
  init_options = {
    userLanguages = {
      templ = "html",
      htmldjango = "html",
    },
  },
}

lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
  settings = {
    pyright = {
      disableLanguageServices = false,
      disableOrganizeImports = false,
    },
    python = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        -- diagnosticMode = "workspace",
        typeCheckingMode = "normal",
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportAttributeAccessIssue = "none",
        },
      },
    },
  },
}

lspconfig.jdtls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "java" },
  root_dir = util.root_pattern "Makefile",
}

lspconfig.gleam.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "gleam" },
}
