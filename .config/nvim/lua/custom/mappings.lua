local set = vim.keymap.set

-- Diagnostic keymaps
set("n", "<leader>lj", vim.diagnostic.goto_prev, { desc = "[L]sp previous [D]iagnostic message" })
set("n", "<leader>lk", vim.diagnostic.goto_next, { desc = "[L]sp next [D]iagnostic message" })
set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "[L]sp [D]iagnostic view" })
set("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "[L]sp diagnostic [Q]uickfix list" })

set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

set("n", "<C-d>", "<C-d>zz", { desc = "Center screen after jumping down" })
set("n", "<C-u>", "<C-u>zz", { desc = "Center screen after jumping up" })

set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

set("n", "<C-w>f", "<C-w>| <C-w>_", { desc = "Max out window" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
