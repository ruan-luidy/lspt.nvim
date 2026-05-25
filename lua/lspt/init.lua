-- lua/lspt/init.lua
-- Entry point do lspt.nvim.
--
-- Uso típico (lazy.nvim):
--
--   {
--     "<seu-fork>/lspt.nvim",
--     ft = "lspt",
--     opts = {
--       -- veja lua/lspt/config.lua para todas as opções
--     },
--   }

local M = {}

---@param opts LsptUserConfig|nil
function M.setup(opts)
  local config = require("lspt.config")
  config.setup(opts)

  require("lspt.commands").register()

  -- Autocmd: inicia o LSP para qualquer buffer .lspt já aberto
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "lspt",
    group   = vim.api.nvim_create_augroup("lspt-attach", { clear = true }),
    callback = function(args)
      require("lspt.lsp").try_start(args.buf)
    end,
  })
end

-- Reexporta APIs públicas
M.config  = function() return require("lspt.config").get() end
M.install = function() require("lspt.server").install(function() end) end
M.restart = function() require("lspt.lsp").restart() end

return M
