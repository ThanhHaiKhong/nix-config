-- lua/keymaps.lua
local km = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Telescope
km("n", "<leader>ff", ":Telescope find_files<CR>", opts)
km("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
km("n", "<leader>gd", ":Telescope lsp_definitions<CR>", opts)

-- Build Swift project
km("n", "<leader>rb", ":!./build.sh<CR>", opts)