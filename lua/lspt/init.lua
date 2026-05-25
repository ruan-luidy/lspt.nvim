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

  -- commands e autocmd FileType já são registrados por plugin/lspt.lua
  -- (carregado automaticamente). Aqui só aplicamos a config do usuário.
  --
  -- Caso já exista um buffer .lspt aberto antes do setup, dispara o attach
  -- manualmente — autocmd FileType só dispara em transição de filetype.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "lspt" then
      require("lspt.lsp").try_start(buf)
    end
  end
end

-- Reexporta APIs públicas
M.config  = function() return require("lspt.config").get() end
M.install = function() require("lspt.server").install(function() end) end
M.restart = function() require("lspt.lsp").restart() end

return M
