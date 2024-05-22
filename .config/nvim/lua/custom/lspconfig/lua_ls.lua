return {
	-- cmd = {...},
	-- filetypes = { ...},
	-- capabilities = {},
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			completion = {
				callSnippet = "Replace",
			},
			-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
			-- diagnostics = { disable = { 'missing-fields' } },
		},
	},
}
