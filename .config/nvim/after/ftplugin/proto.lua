vim.lsp.start({
	name = "protols",
	cmd = { "protols" },
	root_dir = vim.fn.getcwd(),
})
