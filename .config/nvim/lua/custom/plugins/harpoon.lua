return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function(_, opts)
		local harpoon = require("harpoon")

		harpoon:setup(opts)

		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Add to harpoon list" })

		vim.keymap.set("n", "<leader>h", function()
			harpoon:list():select(1)
		end, { desc = "First harpoon file" })
		vim.keymap.set("n", "<leader>j", function()
			harpoon:list():select(2)
		end, { desc = "Second harpoon file" })
		vim.keymap.set("n", "<leader>k", function()
			harpoon:list():select(3)
		end, { desc = "Third harpoon file" })
		vim.keymap.set("n", "<leader>;", function()
			harpoon:list():select(4)
		end, { desc = "Fourth harpoon file" })
	end,
}
