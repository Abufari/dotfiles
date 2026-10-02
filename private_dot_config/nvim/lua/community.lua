-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.catppuccin" },

  -- Python: ruff language server for linting, formatting and import sorting.
  -- NOTE: `pack.python` is deliberately NOT imported as a whole. It pulls in black
  -- and isort (redundant next to ruff) and its basedpyright subpack disables exactly
  -- the type diagnostics a type checker exists for. basedpyright is configured by
  -- hand in `plugins/python.lua` instead.
  { import = "astrocommunity.pack.python.ruff" },

  -- Formatting engine. The ruff subpack registers its formatter chain here, which is
  -- how `ruff_organize_imports` gets to run on save -- import sorting is a code action
  -- and would never be triggered by AstroLSP's `vim.lsp.buf.format()` based hook.
  { import = "astrocommunity.editing-support.conform-nvim" },

  -- Test runner. The Python adapter is wired up in `plugins/python.lua`.
  { import = "astrocommunity.test.neotest" },

  -- Rust: the pack owns the whole stack -- rustaceanvim (which drives rust-analyzer
  -- itself and must therefore disable AstroLSP's own `rust_analyzer` handler),
  -- crates.nvim for Cargo.toml, codelldb for debugging, the taplo TOML server via
  -- `pack.toml`, and the neotest adapter that ships inside rustaceanvim.
  -- Unlike `pack.python` its defaults are sound, and it carries the non-obvious glue
  -- that reconciles rustaceanvim's `root_dir(file, default_fn)` with the
  -- lspconfig-style `root_dir(bufnr, on_dir)` AstroNvim v6 hands out. Two of its
  -- pieces are broken though and are repaired in `plugins/rust.lua` -- see there.
  { import = "astrocommunity.pack.rust" },
}
