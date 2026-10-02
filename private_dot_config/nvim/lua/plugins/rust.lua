-- Rust IDE layer
-- --------------
-- The whole stack (rustaceanvim, crates.nvim, codelldb, taplo, the neotest adapter)
-- comes from `astrocommunity.pack.rust`, see `community.lua`. This file only repairs
-- two upstream defects in that pack; everything else is the pack's.

---@type LazySpec
return {
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    -- WARN: works around a load-order race in `astrocommunity.pack.rust`.
    --
    -- The pack passes rust-analyzer's settings to rustaceanvim by reading
    -- `vim.lsp.config["rust_analyzer"]` inside its `opts` function and closing over
    -- the result. AstroLSP fills that key in its own `setup()`, which AstroNvim runs
    -- on `User AstroFile` -- but rustaceanvim is `ft = "rust"` and therefore loads on
    -- `FileType`, which fires first. Starting Neovim directly on a `.rs` file captures
    -- an empty table and silently drops `check.command = "clippy"` and
    -- `files.exclude`; opening any other buffer beforehand happens to work. Verified
    -- both ways: `cargo clippy` reports `clippy::ptr_arg` on a file where
    -- rust-analyzer stayed quiet.
    --
    -- `init` runs during lazy's startup pass, so the race cannot apply. The key must
    -- be `rust-analyzer` (hyphen, rustaceanvim's `ra_client_name`), not AstroLSP's
    -- `rust_analyzer` -- rustaceanvim re-resolves it in `lsp.start()`, long after
    -- every plugin has loaded, and promotes `settings` to `default_settings` so the
    -- pack's own settings function still layers on top.
    init = function()
      vim.lsp.config("rust-analyzer", {
        settings = {
          ["rust-analyzer"] = {
            -- clippy instead of plain `cargo check`: same cost on save, strictly more lints
            check = { command = "clippy", extraArgs = { "--no-deps" } },
            -- keep the build directory out of the index
            files = { exclude = { ".direnv", ".git", "target" } },
          },
        },
      })
    end,

    -- WARN: second upstream defect in `astrocommunity.pack.rust`.
    --
    -- The pack builds codelldb's `--liblldb` argument as `$MASON/share/lldb/lib/
    -- liblldb.dylib`. Mason no longer installs it there -- the current layout is
    -- `$MASON/opt/lldb/lib/`, with the real file inside the package itself. The
    -- resulting adapter points at a path that does not exist, and nothing complains
    -- until a debug session is actually started. Resolve it by probing instead.
    --
    -- This `opts` function runs after the pack's (`community/` is imported before
    -- `plugins/`), so it receives and patches the table the pack produced.
    opts = function(_, opts)
      -- `$MASON` is only set once mason.nvim has run its setup, which is not
      -- guaranteed at this point -- fall back to the documented default location.
      local mason = vim.env.MASON
      if not mason or mason == "" then mason = vim.fn.stdpath "data" .. "/mason" end
      local ext = vim.uv.os_uname().sysname == "Linux" and ".so" or ".dylib"
      local liblldb
      for _, candidate in ipairs {
        mason .. "/opt/lldb/lib/liblldb" .. ext,
        mason .. "/packages/codelldb/extension/lldb/lib/liblldb" .. ext,
        mason .. "/share/lldb/lib/liblldb" .. ext,
      } do
        if vim.uv.fs_stat(candidate) then
          liblldb = candidate
          break
        end
      end

      local codelldb = vim.fn.exepath "codelldb"
      if codelldb == "" then codelldb = mason .. "/bin/codelldb" end

      if liblldb and vim.uv.fs_stat(codelldb) then
        opts.dap = opts.dap or {}
        opts.dap.adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, liblldb)
      end
    end,
  },
}
