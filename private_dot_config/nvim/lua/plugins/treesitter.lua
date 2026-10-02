-- Customize Treesitter
-- --------------------
-- Since AstroNvim v6 this is configured through AstroCore: nvim-treesitter's `main`
-- branch is only a parser download utility, highlighting and indentation are driven
-- by Neovim's built-in treesitter integration.

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    -- NOTE: must be the function form. lazy.nvim replaces list-like tables on
    -- `opts` merge instead of concatenating them (see `can_merge` in
    -- `lazy.core.util`), so a plain `ensure_installed = { ... }` here would drop
    -- every parser registered by an astrocommunity pack in `community.lua`.
    local treesitter = opts.treesitter or {}
    treesitter.highlight = true
    treesitter.indent = true
    treesitter.auto_install = true -- requires the `tree-sitter` CLI, installed via mason
    treesitter.ensure_installed = require("astrocore").list_insert_unique(treesitter.ensure_installed, {
      "lua",
      "vim",
      "python",
      "rust",
      "toml",
      "markdown",
      "markdown_inline",
    })
    opts.treesitter = treesitter
  end,
}
