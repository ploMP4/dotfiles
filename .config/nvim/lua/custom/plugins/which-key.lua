return {
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		icons = {
			mappings = false,
		},
	},
	config = function(_, opts) -- This is the function that runs, AFTER loading
		require("which-key").setup(opts)

		-- Document existing key chains
		require("which-key").add({
			{ "<leader>f", group = "[F]ind" },
			{ "<leader>g", group = "[G]it" },
		}, {
			mode = { "n", "v" }, -- NORMAL and VISUAL mode
			{ "<leader>l", group = "[L]sp" },
		})
	end,
}
