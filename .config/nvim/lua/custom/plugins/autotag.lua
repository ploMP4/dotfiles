return {
	"windwp/nvim-ts-autotag",
	config = function()
		require("nvim-ts-autotag").setup()
	end,
	ft = {
		"html",
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"tsx",
		"jsx",
		"php",
		"svelte",
		"vue",
		"templ",
		"htmldjango",
	},
}
