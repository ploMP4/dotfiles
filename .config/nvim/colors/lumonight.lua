vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.g.colors_name = "lumonight"
vim.opt.termguicolors = true

-- TokyoNight Night structure with calmer Lumon-like blue accents.
-- These are the immutable BASE colors; the wallpaper accent is applied on top.
local base = {
	bg      = "NONE",
	bg1     = "#141821",
	bg2     = "#1e2533",
	bg3     = "#2a3548",
	bg4     = "#36445c",
	fg      = "#c8d3f5",
	fg_bright = "#dce7ff",
	fg_dim  = "#8da2c9",
	comment = "#5f6f8f",
	blue    = "#7aa2f7",
	frost   = "#9bbcff",
	sky     = "#89dceb",
	cyan    = "#7dcfff",
	teal    = "#8bd5ca",
	steel   = "#6f89bd",
	ice     = "#c3e7ff",
	red     = "#f7768e",
}

-- ---- color math --------------------------------------------------------------
local function hex2rgb(h)
	h = h:gsub("#", "")
	return tonumber(h:sub(1, 2), 16) / 255,
		tonumber(h:sub(3, 4), 16) / 255,
		tonumber(h:sub(5, 6), 16) / 255
end
local function rgb2hsl(r, g, b)
	local mx, mn = math.max(r, g, b), math.min(r, g, b)
	local h, s, l = 0, 0, (mx + mn) / 2
	local d = mx - mn
	if d > 0 then
		s = l > 0.5 and d / (2 - mx - mn) or d / (mx + mn)
		if mx == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif mx == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h / 6
	end
	return h, s, l
end
local function hue2rgb(p, q, t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1 / 6 then return p + (q - p) * 6 * t end
	if t < 1 / 2 then return q end
	if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
	return p
end
local function hsl2hex(h, s, l)
	local r, g, b
	if s == 0 then
		r, g, b = l, l, l
	else
		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1 / 3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1 / 3)
	end
	return string.format("#%02X%02X%02X",
		math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end
-- Interpolate two hex colors in RGB (t in 0..1).
local function lerp(a, b, t)
	local ar, ag, ab = hex2rgb(a)
	local br, bg, bb = hex2rgb(b)
	local function m(x, y) return math.floor((x + (y - x) * t) * 255 + 0.5) end
	return string.format("#%02X%02X%02X", m(ar, br), m(ag, bg), m(ab, bb))
end

-- Build the working palette for a given primary/secondary accent: blue ->
-- primary, frost -> secondary, and the rest of the cool family rotated by the
-- same hue shift, keeping each color's own lightness/saturation. Everything
-- else (bg/fg/comment/red) comes straight from base.
local function build(primary, secondary)
	local c = {}
	for k, v in pairs(base) do
		c[k] = v
	end
	if primary then
		local rot = (select(1, rgb2hsl(hex2rgb(primary)))) - (select(1, rgb2hsl(hex2rgb(base.blue))))
		for _, k in ipairs({ "sky", "cyan", "teal", "steel", "ice" }) do
			local h, s, l = rgb2hsl(hex2rgb(base[k]))
			c[k] = hsl2hex((h + rot) % 1.0, s, l)
		end
		c.blue = primary
		if secondary then
			c.frost = secondary
		end
	end
	return c
end

-- ---- highlight application ---------------------------------------------------
local function apply(c)
	local function hi(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Editor base
	hi("Normal",         { fg = c.fg,       bg = c.bg })
	hi("NormalNC",       { fg = c.fg,       bg = c.bg })
	hi("NormalFloat",    { fg = c.fg,       bg = c.bg1 })
	hi("FloatBorder",    { fg = c.bg4,      bg = c.bg1 })
	hi("FloatTitle",     { fg = c.ice,      bg = c.bg1 })
	hi("EndOfBuffer",    { fg = c.bg2,      bg = c.bg })

	-- Line numbers / cursor
	hi("LineNr",         { fg = c.bg4,      bg = c.bg })
	hi("CursorLineNr",   { fg = c.ice,      bg = c.bg })
	hi("CursorLine",     { bg = c.bg2 })
	hi("CursorColumn",   { bg = c.bg2 })
	hi("ColorColumn",    { bg = c.bg2 })
	hi("SignColumn",     { bg = c.bg })

	-- Window chrome
	hi("WinSeparator",   { fg = c.bg3,      bg = c.bg })
	hi("VertSplit",      { fg = c.bg3,      bg = c.bg })
	hi("Folded",         { fg = c.comment,  bg = c.bg2 })
	hi("FoldColumn",     { fg = c.bg4,      bg = c.bg })

	-- Search / selection
	hi("Search",         { fg = c.bg1,      bg = c.ice })
	hi("IncSearch",      { fg = c.bg1,      bg = c.sky })
	hi("CurSearch",      { fg = c.bg1,      bg = c.sky })
	hi("Visual",         { bg = c.bg3 })
	hi("VisualNOS",      { bg = c.bg3 })

	-- Status / tab line
	hi("StatusLine",     { fg = c.fg_dim,   bg = c.bg1 })
	hi("StatusLineNC",   { fg = c.comment,  bg = c.bg1 })
	hi("TabLine",        { fg = c.fg_dim,   bg = c.bg1 })
	hi("TabLineFill",    { bg = c.bg1 })
	hi("TabLineSel",     { fg = c.ice,      bg = c.bg2 })

	-- Mini statusline
	hi("MiniStatuslineModeNormal",   { fg = c.ice,      bg = c.bg3, bold = true })
	hi("MiniStatuslineModeInsert",   { fg = c.bg1,      bg = c.sky, bold = true })
	hi("MiniStatuslineModeVisual",   { fg = c.bg1,      bg = c.frost, bold = true })
	hi("MiniStatuslineModeReplace",  { fg = c.bg1,      bg = c.red, bold = true })
	hi("MiniStatuslineModeCommand",  { fg = c.bg1,      bg = c.blue, bold = true })
	hi("MiniStatuslineModeOther",    { fg = c.bg1,      bg = c.steel, bold = true })
	hi("MiniStatuslineDevinfo",      { fg = c.fg_dim,   bg = c.bg2 })
	hi("MiniStatuslineFilename",     { fg = c.fg,       bg = c.bg1 })
	hi("MiniStatuslineFileinfo",     { fg = c.fg_dim,   bg = c.bg2 })
	hi("MiniStatuslineInactive",     { fg = c.comment,  bg = c.bg1 })

	-- Completion menu
	hi("Pmenu",          { fg = c.fg,       bg = c.bg1 })
	hi("PmenuSel",       { fg = c.bg1,      bg = c.ice })
	hi("PmenuSbar",      { bg = c.bg2 })
	hi("PmenuThumb",     { bg = c.steel })

	-- Messages
	hi("ErrorMsg",       { fg = c.red })
	hi("WarningMsg",     { fg = c.sky })
	hi("ModeMsg",        { fg = c.fg_dim })
	hi("MoreMsg",        { fg = c.ice })
	hi("Question",       { fg = c.ice })

	-- Diff
	hi("DiffAdd",        { fg = c.teal,     bg = c.bg2 })
	hi("DiffChange",     { fg = c.sky,      bg = c.bg2 })
	hi("DiffDelete",     { fg = c.steel,    bg = c.bg2 })
	hi("DiffText",       { fg = c.ice,      bg = c.bg3 })
	hi("Added",          { fg = c.teal })
	hi("Changed",        { fg = c.sky })
	hi("Removed",        { fg = c.steel })

	-- Spell
	hi("SpellBad",       { sp = c.red,      undercurl = true })
	hi("SpellCap",       { sp = c.ice,      undercurl = true })
	hi("SpellRare",      { sp = c.frost,    undercurl = true })
	hi("SpellLocal",     { sp = c.sky,      undercurl = true })

	-- Syntax (legacy groups)
	hi("Comment",        { fg = c.comment,  italic = true })
	hi("Constant",       { fg = c.frost })
	hi("String",         { fg = c.teal })
	hi("Character",      { fg = c.teal })
	hi("Number",         { fg = c.frost })
	hi("Boolean",        { fg = c.ice })
	hi("Float",          { fg = c.frost })
	hi("Identifier",     { fg = c.fg_bright })
	hi("Function",       { fg = c.frost })
	hi("Statement",      { fg = c.blue })
	hi("Conditional",    { fg = c.blue })
	hi("Repeat",         { fg = c.blue })
	hi("Label",          { fg = c.blue })
	hi("Operator",       { fg = c.fg_dim })
	hi("Keyword",        { fg = c.blue })
	hi("Exception",      { fg = c.blue })
	hi("PreProc",        { fg = c.frost })
	hi("Include",        { fg = c.frost })
	hi("Define",         { fg = c.frost })
	hi("Macro",          { fg = c.frost })
	hi("PreCondit",      { fg = c.frost })
	hi("Type",           { fg = c.frost })
	hi("StorageClass",   { fg = c.blue })
	hi("Structure",      { fg = c.frost })
	hi("Typedef",        { fg = c.frost })
	hi("Special",        { fg = c.cyan })
	hi("SpecialChar",    { fg = c.cyan })
	hi("Tag",            { fg = c.blue })
	hi("Delimiter",      { fg = c.fg_dim })
	hi("SpecialComment", { fg = c.comment })
	hi("Debug",          { fg = c.sky })
	hi("Underlined",     { fg = c.ice, underline = true })
	hi("Ignore",         { fg = c.comment })
	hi("Error",          { fg = c.red })
	hi("Todo",           { fg = c.bg1, bg = c.ice })
	hi("Directory",      { fg = c.ice })

	-- Treesitter
	hi("@comment",                 { link = "Comment" })
	hi("@variable",                { fg = c.fg_bright })
	hi("@variable.builtin",        { fg = c.ice })
	hi("@variable.parameter",      { fg = c.fg })
	hi("@variable.member",         { fg = c.sky })
	hi("@constant",                { fg = c.frost })
	hi("@constant.builtin",        { fg = c.ice })
	hi("@constant.macro",          { fg = c.frost })
	hi("@string",                  { fg = c.teal })
	hi("@string.escape",           { fg = c.ice })
	hi("@string.special",          { fg = c.ice })
	hi("@character",               { fg = c.teal })
	hi("@number",                  { fg = c.frost })
	hi("@boolean",                 { fg = c.ice })
	hi("@float",                   { fg = c.frost })
	hi("@function",                { fg = c.frost })
	hi("@function.builtin",        { fg = c.ice })
	hi("@function.macro",          { fg = c.frost })
	hi("@function.method",         { fg = c.frost })
	hi("@constructor",             { fg = c.frost })
	hi("@keyword",                 { fg = c.blue })
	hi("@keyword.function",        { fg = c.blue })
	hi("@keyword.operator",        { fg = c.blue })
	hi("@keyword.return",          { fg = c.blue })
	hi("@operator",                { fg = c.fg_dim })
	hi("@punctuation.delimiter",   { fg = c.fg_dim })
	hi("@punctuation.bracket",     { fg = c.fg_dim })
	hi("@punctuation.special",     { fg = c.cyan })
	hi("@type",                    { fg = c.frost })
	hi("@type.builtin",            { fg = c.frost })
	hi("@type.qualifier",          { fg = c.blue })
	hi("@namespace",               { fg = c.fg_dim })
	hi("@module",                  { fg = c.fg_dim })
	hi("@label",                   { fg = c.blue })
	hi("@attribute",               { fg = c.frost })
	hi("@tag",                     { fg = c.blue })
	hi("@tag.attribute",           { fg = c.sky })
	hi("@tag.delimiter",           { fg = c.fg_dim })

	-- LSP semantic tokens
	hi("@lsp.type.class",          { link = "@type" })
	hi("@lsp.type.enum",           { link = "@type" })
	hi("@lsp.type.interface",      { link = "@type" })
	hi("@lsp.type.struct",         { link = "@type" })
	hi("@lsp.type.function",       { link = "@function" })
	hi("@lsp.type.method",         { link = "@function.method" })
	hi("@lsp.type.variable",       { link = "@variable" })
	hi("@lsp.type.parameter",      { link = "@variable.parameter" })
	hi("@lsp.type.property",       { link = "@variable.member" })
	hi("@lsp.type.keyword",        { link = "@keyword" })
	hi("@lsp.type.namespace",      { link = "@namespace" })
	hi("@lsp.type.macro",          { link = "@constant.macro" })

	-- Diagnostics
	hi("DiagnosticError",          { fg = c.red })
	hi("DiagnosticWarn",           { fg = c.sky })
	hi("DiagnosticInfo",           { fg = c.ice })
	hi("DiagnosticHint",           { fg = c.fg_dim })
	hi("DiagnosticUnnecessary",    { fg = c.comment })
	hi("DiagnosticUnderlineError", { sp = c.red,      undercurl = true })
	hi("DiagnosticUnderlineWarn",  { sp = c.sky,      undercurl = true })
	hi("DiagnosticUnderlineInfo",  { sp = c.ice,      undercurl = true })
	hi("DiagnosticUnderlineHint",  { sp = c.fg_dim,   undercurl = true })

	-- Git signs
	hi("GitSignsAdd",              { fg = c.teal })
	hi("GitSignsChange",           { fg = c.sky })
	hi("GitSignsDelete",           { fg = c.steel })

	-- Oil
	hi("OilDir",                   { fg = c.ice })
	hi("OilDirIcon",               { fg = c.ice })
	hi("OilFile",                  { fg = c.fg })
	hi("OilHidden",                { fg = c.comment })
	hi("OilFileHidden",            { fg = c.comment })
	hi("OilDirHidden",             { fg = c.comment })
	hi("OilLink",                  { fg = c.sky })
	hi("OilLinkTarget",            { fg = c.comment })
	hi("OilCreate",                { fg = c.ice })
	hi("OilChange",                { fg = c.sky })
	hi("OilMove",                  { fg = c.sky })
	hi("OilCopy",                  { fg = c.fg_dim })

	-- Telescope
	hi("TelescopeNormal",          { fg = c.fg,       bg = c.bg1 })
	hi("TelescopeBorder",          { fg = c.bg4,      bg = c.bg1 })
	hi("TelescopeSelection",       { fg = c.fg,       bg = c.bg3 })
	hi("TelescopeSelectionCaret",  { fg = c.ice })
	hi("TelescopeMatching",        { fg = c.ice })
	hi("TelescopePromptNormal",    { fg = c.fg,       bg = c.bg2 })
	hi("TelescopePromptBorder",    { fg = c.ice,      bg = c.bg2 })
	hi("TelescopePromptTitle",     { fg = c.bg1,      bg = c.ice })
	hi("TelescopePreviewTitle",    { fg = c.bg1,      bg = c.sky })
	hi("TelescopeResultsTitle",    { fg = c.bg4,      bg = c.bg1 })

	-- Which-key
	hi("WhichKey",                 { fg = c.ice })
	hi("WhichKeyGroup",            { fg = c.sky })
	hi("WhichKeyDesc",             { fg = c.fg_dim })
	hi("WhichKeySeparator",        { fg = c.comment })
	hi("WhichKeyFloat",            { bg = c.bg1 })
	hi("WhichKeyBorder",           { fg = c.bg4,      bg = c.bg1 })

	-- Indent blankline
	hi("IblIndent",                { fg = c.bg2 })
	hi("IblScope",                 { fg = c.bg4 })

	-- Bufferline
	hi("BufferLineFill",           { bg = c.bg1 })
	hi("BufferLineBackground",     { fg = c.comment,  bg = c.bg1 })
	hi("BufferLineSelected",       { fg = c.ice,      bg = c.bg2 })
	hi("BufferLineSeparator",      { fg = c.bg1,      bg = c.bg1 })
end

-- ---- wallpaper accent + animation -------------------------------------------
-- Read the wallpaper accents (primary, secondary) written by wallust-apply.sh.
local function read_accent()
	local f = io.open(os.getenv("HOME") .. "/.cache/wallust/accent", "r")
	if not f then
		return nil, nil
	end
	local a = f:read("l")
	local b = f:read("l")
	f:close()
	if a and not a:match("^#%x%x%x%x%x%x$") then a = nil end
	if b and not b:match("^#%x%x%x%x%x%x$") then b = nil end
	return a, b
end

-- Initial paint when the colorscheme loads (no animation).
do
	local p, s = read_accent()
	vim.g.lumonight_primary = p or base.blue
	vim.g.lumonight_secondary = s or base.frost
	apply(build(vim.g.lumonight_primary, vim.g.lumonight_secondary))
end

-- Smoothly transition to the current accent file instead of snapping. Called by
-- wallust-apply.sh (via :LumonightAnimate) on a wallpaper change.
local uv = vim.uv or vim.loop
local anim_timer
function _G.lumonight_animate()
	if (vim.g.colors_name or "") ~= "lumonight" then
		return
	end
	local tp, ts = read_accent()
	tp = tp or base.blue
	ts = ts or base.frost
	local fp = vim.g.lumonight_primary or base.blue
	local fs = vim.g.lumonight_secondary or base.frost
	if fp == tp and fs == ts then
		return
	end
	if anim_timer then
		anim_timer:stop()
		anim_timer:close()
		anim_timer = nil
	end
	local steps, i = 30, 0
	anim_timer = uv.new_timer()
	anim_timer:start(0, 16, vim.schedule_wrap(function()
		i = i + 1
		local t = i / steps
		apply(build(lerp(fp, tp, t), lerp(fs, ts, t)))
		if i >= steps then
			if anim_timer then
				anim_timer:stop()
				anim_timer:close()
				anim_timer = nil
			end
			vim.g.lumonight_primary = tp
			vim.g.lumonight_secondary = ts
		end
	end))
end

vim.api.nvim_create_user_command("LumonightAnimate", function()
	_G.lumonight_animate()
end, {})
