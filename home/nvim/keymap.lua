-- keymaps.lua - Enhanced Key Mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- GENERAL KEYMAPS
-- ============================================================================

-- Better escape
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Save and quit
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)
keymap("n", "<leader>wq", ":wq<CR>", opts)
keymap("n", "<leader>x", ":x<CR>", opts)

-- Better window navigation (vim-tmux-navigator will override these for tmux integration)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer navigation
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)
keymap("n", "<leader>ba", ":bufdo bdelete<CR>", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual --
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Clear search highlighting
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)

-- ============================================================================
-- TELESCOPE KEYMAPS
-- ============================================================================

keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>fr", ":Telescope oldfiles<CR>", opts)
keymap("n", "<leader>fc", ":Telescope commands<CR>", opts)
keymap("n", "<leader>fk", ":Telescope keymaps<CR>", opts)
keymap("n", "<leader>fs", ":Telescope git_status<CR>", opts)
keymap("n", "<leader>fm", ":Telescope marks<CR>", opts)

-- LSP with Telescope
keymap("n", "<leader>gd", ":Telescope lsp_definitions<CR>", opts)
keymap("n", "<leader>gr", ":Telescope lsp_references<CR>", opts)
keymap("n", "<leader>gi", ":Telescope lsp_implementations<CR>", opts)
keymap("n", "<leader>gt", ":Telescope lsp_type_definitions<CR>", opts)
keymap("n", "<leader>ds", ":Telescope lsp_document_symbols<CR>", opts)
keymap("n", "<leader>ws", ":Telescope lsp_workspace_symbols<CR>", opts)

-- ============================================================================
-- FILE TREE KEYMAPS (Neo-tree)
-- ============================================================================

keymap("n", "<leader>e", ":Neotree toggle<CR>", opts)
keymap("n", "<leader>o", ":Neotree focus<CR>", opts)
keymap("n", "<leader>nf", ":Neotree reveal<CR>", opts)
keymap("n", "<leader>ng", ":Neotree git_status<CR>", opts)
keymap("n", "<leader>nb", ":Neotree buffers<CR>", opts)

-- ============================================================================
-- GIT KEYMAPS
-- ============================================================================

-- Git signs
keymap("n", "<leader>gj", ":Gitsigns next_hunk<CR>", opts)
keymap("n", "<leader>gk", ":Gitsigns prev_hunk<CR>", opts)
keymap("n", "<leader>gl", ":Gitsigns blame_line<CR>", opts)
keymap("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", opts)
keymap("n", "<leader>gh", ":Gitsigns reset_hunk<CR>", opts)
keymap("n", "<leader>gR", ":Gitsigns reset_buffer<CR>", opts)
keymap("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", opts)
keymap("n", "<leader>gS", ":Gitsigns stage_buffer<CR>", opts)
keymap("n", "<leader>gu", ":Gitsigns undo_stage_hunk<CR>", opts)
keymap("n", "<leader>gd", ":Gitsigns diffthis<CR>", opts)

-- Git fugitive
keymap("n", "<leader>G", ":Git<CR>", opts)
keymap("n", "<leader>gc", ":Git commit<CR>", opts)
keymap("n", "<leader>gP", ":Git push<CR>", opts)
keymap("n", "<leader>gL", ":Git pull<CR>", opts)

-- ============================================================================
-- TERMINAL KEYMAPS
-- ============================================================================

keymap("n", "<leader>tf", ":ToggleTerm direction=float<CR>", opts)
keymap("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", opts)
keymap("n", "<leader>tv", ":ToggleTerm direction=vertical size=80<CR>", opts)

-- Terminal mappings
function _G.set_terminal_keymaps()
  local term_opts = { buffer = 0 }
  keymap('t', '<esc>', [[<C-\><C-n>]], term_opts)
  keymap('t', 'jk', [[<C-\><C-n>]], term_opts)
  keymap('t', '<C-h>', [[<Cmd>wincmd h<CR>]], term_opts)
  keymap('t', '<C-j>', [[<Cmd>wincmd j<CR>]], term_opts)
  keymap('t', '<C-k>', [[<Cmd>wincmd k<CR>]], term_opts)
  keymap('t', '<C-l>', [[<Cmd>wincmd l<CR>]], term_opts)
  keymap('t', '<C-w>', [[<C-\><C-n><C-w>]], term_opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- ============================================================================
-- DIAGNOSTICS & TROUBLE
-- ============================================================================

keymap("n", "<leader>xx", ":TroubleToggle<CR>", opts)
keymap("n", "<leader>xw", ":TroubleToggle workspace_diagnostics<CR>", opts)
keymap("n", "<leader>xd", ":TroubleToggle document_diagnostics<CR>", opts)
keymap("n", "<leader>xl", ":TroubleToggle loclist<CR>", opts)
keymap("n", "<leader>xq", ":TroubleToggle quickfix<CR>", opts)
keymap("n", "gR", ":TroubleToggle lsp_references<CR>", opts)

-- ============================================================================
-- COMMENT KEYMAPS
-- ============================================================================

-- Comment.nvim keymaps are set automatically, but we can override:
keymap("n", "<leader>/", function()
  require("Comment.api").toggle.linewise.current()
end, opts)

keymap("v", "<leader>/", function()
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, opts)

-- ============================================================================
-- FORMATTING KEYMAPS
-- ============================================================================

keymap("n", "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, opts)

-- ============================================================================
-- SESSION MANAGEMENT
-- ============================================================================

keymap("n", "<leader>qs", function() require("persistence").load() end, opts)
keymap("n", "<leader>ql", function() require("persistence").load({ last = true }) end, opts)
keymap("n", "<leader>qd", function() require("persistence").stop() end, opts)

-- ============================================================================
-- ADDITIONAL PLUGIN KEYMAPS
-- ============================================================================

-- Clear hlslens highlight
keymap("n", "<leader>l", ":noh<CR>", opts)

-- ============================================================================
-- MISCELLANEOUS
-- ============================================================================

-- Quick source config
keymap("n", "<leader>so", ":so %<CR>", opts)

-- Quick edit config
keymap("n", "<leader>ev", ":edit $MYVIMRC<CR>", opts)

-- Better join lines
keymap("n", "J", "mzJ`z", opts)

-- Center screen when scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Center screen when searching
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Project specific keymaps
-- Build Swift project
keymap("n", "<leader>rb", ":!./build.sh<CR>", opts)

-- Run current file
keymap("n", "<leader>rf", ":!%:p<CR>", opts)

-- Make file executable
keymap("n", "<leader>rx", ":!chmod +x %<CR>", opts)