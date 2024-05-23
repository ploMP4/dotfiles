return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").setup()

		-- Document existing key chains
		require("which-key").register({
			["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
			["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
			["<leader>l"] = { name = "[L]sp", _ = "which_key_ignore" },
		})
		-- visual mode
		require("which-key").register({
			["<leader>l"] = { "[L]sp" },
		}, { mode = "v" })
	end,
}
