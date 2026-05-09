vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.g.colors_name = "lumonight"
vim.opt.termguicolors = true

-- TokyoNight Night structure with calmer Lumon-like blue accents.
local c = {
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
