return {
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	{
		"numToStr/Comment.nvim",
		opts = {
			toggler = {
				line = "<leader>/",
			},
			opleader = {
				line = "<leader>/",
			},
		},
	},

	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = { transparent = true },
	},

	{
		name = "lumonight",
		dir = vim.fn.stdpath("config"),
		priority = 1001,
		config = function()
			vim.cmd.colorscheme("lumonight")
		end,
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"echasnovski/mini.nvim",
		config = function()
			-- require("mini.ai").setup({ n_lines = 500 })
			--
			--

			local bufremove = require("mini.bufremove")
			bufremove.setup({})
			local function close_other_buffers()
				local current_buf = vim.api.nvim_get_current_buf()
				local all_bufs = vim.api.nvim_list_bufs()

				for _, buf in ipairs(all_bufs) do
					if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
						bufremove.delete(buf)
					end
				end
			end

			vim.keymap.set("n", "<leader>c", bufremove.delete, { desc = "[C]lose current buffer" })
			vim.keymap.set("n", "<leader>x", close_other_buffers, { desc = "[X]lose all buffers" })

			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},
}
