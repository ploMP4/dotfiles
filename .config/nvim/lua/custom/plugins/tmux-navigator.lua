-- Inside Herdr (no tmux) there is no tmux pane to hand off to: Herdr's dots
-- layout passes ctrl+h/j/k/l to nvim, so move between nvim splits and, at the
-- edge, ask Herdr to focus its pane in that direction instead.
--
-- Only where the Herdr window itself runs: a terminal on another machine
-- (Herdr's remote spaces) has HC_TERMINAL_ID too, but `herdr-app` there would
-- be missing or drive a different window. The window's control socket is the
-- tell. Elsewhere the TmuxNavigate* mappings stay (plain wincmd outside tmux).
local function herdr_window_here()
	if vim.env.HC_TERMINAL_ID == nil or vim.env.TMUX ~= nil then
		return false
	end
	if vim.fn.executable("herdr-app") ~= 1 then
		return false
	end
	local app_home = vim.env.HERDR_APP_HOME or (vim.env.HOME .. "/.config/herdr-app")
	local stat = vim.uv.fs_stat(app_home .. "/herdr-app.sock")
	return stat ~= nil and stat.type == "socket"
end

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
		local in_herdr = herdr_window_here()
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
