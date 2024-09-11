-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = {
  "cssls",
  "html",
  "lua_ls",
  "gopls",
  "clangd",
  "rust_analyzer"
}

require'lspconfig'.omnisharp.setup {
    cmd = { "dotnet", "C:\\Users\\MihirLuthra\\AppData\\Local\\nvim-data\\mason\\packages\\omnisharp\\libexec\\OmniSharp.dll" },

    -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
    enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = false,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = false,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = false,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
    sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = false,
}

-- Adds support to lua-language-server for init.lua
-- and plugin development
require("neodev").setup {}

-- lsps witdefault config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  commands = {
    -- https://www.reddit.com/r/rust/comments/w7cf7d/comment/ihjur2p/
    -- https://github.com/Shatur/neovim-config/blob/master/plugin/lsp.lua#L155-L167
    RustOpenDocs = {
      function()
        vim.lsp.buf_request(
          vim.api.nvim_get_current_buf(),
          "experimental/externalDocs",
          vim.lsp.util.make_position_params(),
          function(err, url)
            if err then
              error(tostring(err))
            else
              vim.fn["netrw#BrowseX"](url, 0)
            end
          end
        )
      end,
      description = "Open documentation for the symbol under the cursor in default browser",
    },
  },
}

-- lspconfig.bashls.setup {
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
--   settings = {
--     -- https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
--     -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/bashls.lua
--     bashIde = {
--       backgroundAnalysisMaxFiles = 1000,
--       globPattern = "**/*@(.sh|.inc|.bash|.command)",
--       includeAllWorkspaceSymbols = true,
--       logLevel = "debug",
--     },
--   },
-- }
