return {
	"akinsho/bufferline.nvim",
	version = "*",
	config = function(_, opts)
		vim.opt.termguicolors = true
		require("bufferline").setup(opts)

		vim.keymap.set("n", "<S-l>", "<cmd> BufferLineCycleNext<CR>", { desc = "Go to next tab" })
		vim.keymap.set("n", "<S-h>", "<cmd> BufferLineCyclePrev<CR>", { desc = "Go to prev tab" })
	end,
	dependencies = "nvim-tree/nvim-web-devicons",
}
