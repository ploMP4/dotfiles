return {
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
