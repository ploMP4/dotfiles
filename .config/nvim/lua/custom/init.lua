vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.colorcolumn = "80"

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.filetype.add {
  extension = {
    templ = "templ",
  },
}

-- local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
-- treesitter_parser_config.templ = {
--   install_info = {
--     url = "https://github.com/vrischmann/tree-sitter-templ.git",
--     files = { "src/parser.c", "src/scanner.c" },
--     branch = "master",
--   },
-- }
--
-- vim.treesitter.language.register("templ", "templ")
