local util = require("lspconfig/util")

return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork" },
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			hints = {
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			codelenses = {
				generate = true, -- show the `go generate` lens.
				gc_details = true, -- show a code lens toggling the display of gc's choices.
				test = true,
				upgrade_dependency = true,
				tidy = true,
			},
		},
	},
}
