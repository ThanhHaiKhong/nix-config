-- lua/lsp.lua
-- LSP configuration

local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Swift: SourceKit-LSP
lspconfig.sourcekit.setup({
  capabilities = capabilities,
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift", "objective-c", "objective-cpp" },
  root_dir = lspconfig.util.root_pattern("Package.swift", ".git", "project.pbxproj"),
})

-- Objective-C: clangd
lspconfig.clangd.setup({
  capabilities = capabilities,
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
})