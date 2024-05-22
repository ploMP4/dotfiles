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
				typeCheckingMode = "normal",
				useLibraryCodeForTypes = true,
				diagnosticSeverityOvverides = {
					reportAttributeAccessIssue = "none",
				},
			},
		},
	},
}
