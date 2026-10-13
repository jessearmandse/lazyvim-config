-- Tools marked as system-managed are installed outside Mason (mise, pnpm), so
-- Mason must not try to install them. Mason installs npm packages at the exact
-- version its registry pins, which npm's `min-release-age` rejects while that
-- version is newer than the age window.
local system_managed = { "oxfmt" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      formatting = {
        disabled = {
          "lua_ls",
        },
      },
      servers = {
        -- Python: ty for type checking, ruff for linting/formatting
        -- Uses vim.lsp.config() + vim.lsp.enable() (Neovim 0.11+ API)
        ty = {
          settings = {
            ty = {
              -- Per-project config via ty.toml or pyproject.toml is preferred
            },
          },
        },
        -- Disable pylsp — replaced by ty + ruff
        pylsp = { enabled = false },
        lua_ls = {
          Lua = {
            validate = { enable = true },
            format = { enable = false },
          },
        },
        jsonls = {
          settings = {
            json = {
              validate = { enable = true },
              format = { enable = false }, -- oxfmt handles formatting
            },
          },
        },
        -- System-managed servers (mise / pnpm), resolved from $PATH
        oxlint = { mason = false },
        yamlls = { mason = false },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    -- ensure_installed is an opts_extend list, so a table here would append;
    -- removing entries that extras added needs a function.
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not vim.tbl_contains(system_managed, pkg)
      end, opts.ensure_installed or {})
    end,
  },
}
