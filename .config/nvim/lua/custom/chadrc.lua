---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "tokyonight",
  transparency = true,

  statusline = {
    theme = "vscode_colored",
    separator_style = "block",
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
