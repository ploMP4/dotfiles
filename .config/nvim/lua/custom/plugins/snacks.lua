return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		picker = {
			layout = {
				preset = "right",
			},
		},
	},
	keys = {
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "[F]ind [H]elp",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "[F]ind [K]eymaps",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.git_files()
			end,
			desc = "[F]ind git [F]iles",
		},
		{
			"<leader>fa",
			function()
				Snacks.picker.files()
			end,
			desc = "[F]ind [A]ll files",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.pickers()
			end,
			desc = "[F]ind [S]elect picker",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "[F]ind current [W]ord",
			mode = { "n", "x" },
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "[F]ind by [G]rep",
		},
		{
			"<leader>le",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "[L]sp [E]rrors",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.resume()
			end,
			desc = "[F]ind [R]esume",
		},
		{
			"<leader>f.",
			function()
				Snacks.picker.recent()
			end,
			desc = "[F]ind Recent Files",
		},
		{
			"<leader><leader>",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Find existing buffers",
		},
		{
			"<leader>gc",
			function()
				Snacks.picker.git_log()
			end,
			desc = "[G]it [C]ommits",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "[G]it [S]tatus",
		},
		{
			"<leader>f/",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "[F]ind [/] in Open Buffers",
		},
		{
			"<leader>fn",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "[F]ind [N]eovim config files",
		},
	},
}
