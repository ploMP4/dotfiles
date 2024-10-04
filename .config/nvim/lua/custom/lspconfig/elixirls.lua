local util = require("lspconfig/util")

return {
	cmd = { "/home/plo/.local/share/nvim/mason/bin/elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex" },
	root_dir = util.root_pattern("mix.exs", ".git"),
}
