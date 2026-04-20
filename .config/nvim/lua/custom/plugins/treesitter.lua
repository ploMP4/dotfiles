return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				local ft = vim.bo[buf].filetype
				local lang = vim.treesitter.language.get_lang(ft)
				if lang and pcall(vim.treesitter.start, buf, lang) then
					if ft ~= "ruby" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
					if ft == "ruby" then
						vim.treesitter.stop(buf)
						vim.bo[buf].syntax = "on"
					end
				end
			end,
		})
	end,
}
