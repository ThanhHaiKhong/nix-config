-- lua/formatter.lua
-- Code formatting configuration

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.swiftformat,
    null_ls.builtins.diagnostics.swiftlint,
    null_ls.builtins.formatting.clang_format,
  },
})