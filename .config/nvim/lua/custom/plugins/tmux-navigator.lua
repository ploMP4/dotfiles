-- Inside Herdr (no tmux) there is no tmux pane to hand off to: Herdr's dots
-- layout passes ctrl+h/j/k/l to nvim, so move between nvim splits and, at the
-- edge, ask Herdr to focus its pane in that direction instead.
local function herdr_nav(wincmd, direction)
	return function()
		local before = vim.fn.winnr()
		vim.cmd("wincmd " .. wincmd)
		if vim.fn.winnr() == before then
			vim.system({ "herdr-app", "do", "pane.go", "--direction", direction })
		end
	end
end

return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	config = function()
		local in_herdr = vim.env.HC_TERMINAL_ID ~= nil and vim.env.TMUX == nil
		local function map(key, tmux_cmd, wincmd, direction, desc)
			local action = in_herdr and herdr_nav(wincmd, direction) or ("<cmd> " .. tmux_cmd .. "<CR>")
			vim.keymap.set("n", key, action, { desc = desc })
		end
		map("<C-h>", "TmuxNavigateLeft", "h", "left", "window left")
		map("<C-l>", "TmuxNavigateRight", "l", "right", "window right")
		map("<C-j>", "TmuxNavigateDown", "j", "down", "window down")
		map("<C-k>", "TmuxNavigateUp", "k", "up", "window up")
	end,
}
