-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      -- NOTE: `codelens` is deliberately not set here. AstroNvim version-gates its
      -- default (`_astrolsp.lua`): enabled everywhere except Neovim 0.12.0-0.12.1,
      -- where the upstream implementation is broken. Hardcoding `true` would
      -- re-enable it there.
      inlay_hints = true, -- inferred types/return values; toggle per buffer with `<Leader>uH`
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- NOTE: formatting is deliberately NOT configured here. conform.nvim (see
    -- `community.lua`) owns it and sets `formatting.disabled = true` on AstroLSP.
    -- Defining a `formatting` table here would override that and cause both
    -- AstroLSP's and conform's format-on-save hooks to run on every write.
    -- Autoformat toggles: `<Leader>uf` (buffer) / `<Leader>uF` (global).
    -- enable servers that you already have installed without mason
    servers = {},
    -- customize language server configuration passed to `vim.lsp.config`
    -- client specific configuration can also go in `lsp/` in your configuration root (see `:h lsp-config`)
    config = {
      -- ["*"] = { capabilities = {} }, -- modify default LSP client settings such as capabilities
    },
    -- customize how language servers are attached
    handlers = {
      -- a function with the key `*` modifies the default handler, functions takes the server name as the parameter
      -- ["*"] = function(server) vim.lsp.enable(server) end

      -- the key is the server that is being setup with `vim.lsp.config`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
    },
    -- Configure buffer local auto commands to add when attaching a language server
    -- NOTE: no `lsp_codelens_refresh` here. AstroNvim already registers that augroup
    -- in `_astrolsp_autocmds.lua`, gated on `vim.lsp.codelens.enable` being absent
    -- (Neovim < 0.12) and calling the 0.11 API `vim.lsp.codelens.refresh`. Redefining
    -- the augroup under the same key replaces that callback on merge.
    autocmds = {},
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    -- A custom `on_attach` function can be added here, taking `client` and `bufnr`
    -- (`:h lsp-attach`). NOTE: ruff's `hoverProvider` is disabled by
    -- `astrocommunity.pack.python.ruff`, so hover always comes from basedpyright.
  },
}
