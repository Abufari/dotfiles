-- Python IDE layer
-- ----------------
-- basedpyright  -> types, completion, hover, goto, inlay hints, auto-imports
-- ruff          -> linting, formatting, import sorting (via `community.lua`)
-- neotest       -> pytest integration (runner comes from `astrocommunity.test.neotest`)

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "basedpyright" })
    end,
  },

  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        basedpyright = {
          -- Resolve the interpreter explicitly. basedpyright only auto-detects a
          -- `.venv` next to the workspace root; central venvs and an activated shell
          -- env would otherwise silently fall back to the system interpreter and
          -- report every third-party import as missing.
          before_init = function(params, config)
            local root = config.root_dir
            if type(root) ~= "string" then root = params.rootPath end
            if type(root) ~= "string" then root = vim.fn.getcwd() end

            -- Order matters: a project-local venv must beat a `VIRTUAL_ENV` inherited
            -- from the shell, otherwise opening a project from an activated unrelated
            -- venv resolves every import against the wrong interpreter.
            local candidates = { root .. "/.venv/bin/python", root .. "/venv/bin/python" }
            if vim.env.VIRTUAL_ENV then table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python") end
            table.insert(candidates, vim.fn.exepath "python3")

            local python = candidates[#candidates]
            for _, candidate in ipairs(candidates) do
              if vim.fn.executable(candidate) == 1 then
                python = candidate
                break
              end
            end
            -- NOTE: must mutate in place. `client.settings` holds a reference to this
            -- exact table, so replacing it (e.g. via `vim.tbl_deep_extend`) would only
            -- reach the initialize params and never `workspace/didChangeConfiguration`.
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python
          end,
          settings = {
            basedpyright = {
              analysis = {
                -- basedpyright's own default is "recommended", which promotes every
                -- rule to error and is unworkable on untyped scientific code.
                -- "standard" is the pyright-equivalent level.
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                -- "workspace" re-analyses the whole tree on every change; painful on
                -- anything with a large dependency surface.
                diagnosticMode = "openFilesOnly",
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                  callArgumentNames = true,
                  genericTypes = false, -- extremely noisy with numpy/torch generics
                },
                diagnosticSeverityOverrides = {
                  -- ruff already reports these (F401/F841), don't duplicate
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                  -- numpy/scipy/torch re-export heavily through private modules
                  reportPrivateImportUsage = "none",
                  reportMissingTypeStubs = "none",
                },
              },
            },
          },
        },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { { "nvim-neotest/neotest-python", config = function() end } },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      -- runner is auto-detected (pytest when available, else unittest)
      table.insert(opts.adapters, require "neotest-python" {})
    end,
  },
}
