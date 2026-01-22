-- options.lua - Enhanced Vim Options
local opt = vim.opt
local g = vim.g

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

-- Disable netrw (we use nvim-tree)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Leader key
g.mapleader = " "
g.maplocalleader = " "

-- File encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- ============================================================================
-- UI SETTINGS
-- ============================================================================

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4

-- Sign column
opt.signcolumn = "yes"

-- Cursor line/column
opt.cursorline = true
opt.cursorcolumn = false

-- Color settings
opt.termguicolors = true
opt.background = "dark"

-- Tmux integration
if vim.env.TMUX then
  vim.cmd('set t_Co=256')
end

-- Window splitting
opt.splitbelow = true
opt.splitright = true

-- Status line and command line
opt.laststatus = 3  -- Global statusline
opt.showmode = false  -- Don't show mode in command line (lualine handles this)
opt.showcmd = true
opt.cmdheight = 1

-- Popup menu
opt.pumheight = 10
opt.pumblend = 10

-- Windows and buffers
opt.winblend = 0
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- ============================================================================
-- EDITING BEHAVIOR
-- ============================================================================

-- Indentation
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true

-- Text wrapping
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.showbreak = "↳ "

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true

-- Mouse support
opt.mouse = "a"
opt.mousemodel = "popup"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- ============================================================================
-- SEARCH AND REPLACE
-- ============================================================================

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true

-- Global substitution by default
opt.gdefault = true

-- ============================================================================
-- COMPLETION
-- ============================================================================

opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Completion behavior
opt.complete:append("kspell")
opt.dictionary = "/usr/share/dict/words"

-- ============================================================================
-- FOLDING
-- ============================================================================

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = {
  foldopen = " ",
  foldclose = " ",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- ============================================================================
-- FILES AND BACKUP
-- ============================================================================

-- Backup and swap files
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Persistent undo
opt.undofile = true
opt.undolevels = 10000

-- File watching
opt.autoread = true
opt.updatetime = 200

-- Hidden buffers
opt.hidden = true

-- ============================================================================
-- PERFORMANCE
-- ============================================================================

-- Faster completion
opt.timeoutlen = 300
opt.ttimeoutlen = 0

-- Lazy redraw for macros
opt.lazyredraw = false

-- Maximum memory for pattern matching
opt.maxmempattern = 20000

-- ============================================================================
-- FORMATTING
-- ============================================================================

-- Format options
opt.formatoptions = opt.formatoptions
  - "a"  -- Don't auto format
  - "t"  -- Don't auto wrap text
  + "c"  -- Auto wrap comments
  + "q"  -- Allow formatting comments with gq
  - "o"  -- Don't continue comments with O/o
  + "r"  -- Continue comments with Enter
  + "n"  -- Recognize numbered lists
  + "j"  -- Remove comment when joining lines
  - "2"  -- Don't use second line indent

-- Text width
opt.textwidth = 80
opt.colorcolumn = "80,120"

-- ============================================================================
-- SPELLING
-- ============================================================================

opt.spell = false
opt.spelllang = { "en_us" }
opt.spelloptions = "camel"

-- ============================================================================
-- DIFF OPTIONS
-- ============================================================================

opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "hiddenoff",
  "algorithm:minimal",
}

-- ============================================================================
-- SESSION OPTIONS
-- ============================================================================

opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}

-- ============================================================================
-- WILDIGNORE
-- ============================================================================

opt.wildignore:append({
  "*.o,*.obj,*~",
  "*.git*",
  "*.meteor*",
  "*vim/backups*",
  "*sass-cache*",
  "*mypy_cache*",
  "*__pycache__*",
  "*cache*",
  "*logs*",
  "*node_modules*",
  "**/node_modules/**",
  "*DS_Store*",
  "*.gem",
  "log/**",
  "tmp/**",
  "*.png,*.jpg,*.gif",
})

-- ============================================================================
-- LANGUAGE SPECIFIC SETTINGS
-- ============================================================================

-- Python
g.python3_host_prog = vim.fn.exepath("python3")

-- Node.js
g.node_host_prog = vim.fn.exepath("neovim-node-host")

-- Ruby (if needed)
g.ruby_host_prog = vim.fn.exepath("neovim-ruby-host")

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Auto resize panes when resizing nvim window
augroup("ResizePanes", { clear = true })
autocmd("VimResized", {
  group = "ResizePanes",
  command = "tabdo wincmd =",
})

-- Close certain filetypes with <q>
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = "CloseWithQ",
  pattern = {
    "qf", "help", "man", "notify", "lspinfo", "spectre_panel",
    "startuptime", "tsplayground", "PlenaryTestPopup"
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto create directories when saving a file
augroup("AutoCreateDir", { clear = true })
autocmd("BufWritePre", {
  group = "AutoCreateDir",
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Return to last edit position when opening files
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- File type specific settings
augroup("FileTypeSettings", { clear = true })

-- Git commit messages
autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Markdown files
autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})

-- YAML files
autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})