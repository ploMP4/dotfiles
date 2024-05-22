local util = require("lspconfig/util")

return {
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
