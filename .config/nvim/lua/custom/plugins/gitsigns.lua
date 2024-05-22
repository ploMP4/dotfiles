return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	},
	config = function(_, opts)
		local gitsigns = require("gitsigns")
		gitsigns.setup(opts)

		vim.keymap.set("n", "<leader>ghn", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gitsigns.next_hunk()
			end)
			return "<Ignore>"
		end, { desc = "Jump to next hunk", expr = true })

		vim.keymap.set("n", "<leader>ghb", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gitsigns.prev_hunk()
			end)
			return "<Ignore>"
		end, { desc = "Jump to prev hunk", expr = true })

		vim.keymap.set("n", "<leader>ghp", gitsigns.preview_hunk, { desc = "[G]it [H]unk [P]review" })
		vim.keymap.set("n", "<leader>ghr", gitsigns.reset_hunk, { desc = "[G]it [H]unk [R]eset" })
		vim.keymap.set("n", "<leader>ghs", gitsigns.stage_hunk, { desc = "[G]it [H]unk [S]tage" })
		vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "[G]it [B]lame" })
		vim.keymap.set("n", "<leader>gtd", gitsigns.toggle_deleted, { desc = "[G]it [T]oggle [D]eleted" })
		vim.keymap.set("n", "<leader>gd", gitsigns.diffthis, { desc = "[G]it [D]iff" })
	end,
}
