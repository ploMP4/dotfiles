local util = require("lspconfig/util")

return {
	cmd = { "zls" },
	filetypes = { "zig", "zir" },
	root_dir = util.root_pattern("zls.json", "build.zig"),
	single_file_support = true,
	warn_style = true,
}
