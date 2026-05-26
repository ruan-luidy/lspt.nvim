-- lua/lspt/snippets.lua
-- Carrega e registra os snippets da Linguagem Senior.
--
-- A lista de snippets (em `snippets_data.lua`) sempre está disponível.
-- O registro em runtime depende do LuaSnip — se não estiver instalado,
-- `setup_buffer()` vira no-op silencioso, mas `list()` continua funcionando
-- para `:LsptSnippets`.
--
-- Formato VSCode (`$1`, `${1:default}`) é traduzido pelo parser nativo do
-- LuaSnip via `ls.parser.parse_snippet`.

local M = {}

local data = require("lspt.snippets_data")
local registered = false

function M.list()
  return data
end

function M.setup_buffer()
  if registered then return end

  local ok, ls = pcall(require, "luasnip")
  if not ok then return end

  -- Converte tabs do corpo dos snippets para espaços do buffer atual.
  -- O parser do LuaSnip não respeita expandtab/shiftwidth automaticamente.
  local sw = (vim.bo.shiftwidth > 0) and vim.bo.shiftwidth or 2
  local indent = string.rep(" ", sw)

  local snippets = {}
  for _, item in ipairs(data) do
    local body = table.concat(item.body, "\n"):gsub("\t", indent)
    local snip = ls.parser.parse_snippet(
      { trig = item.prefix, name = item.name, dscr = item.description },
      body
    )
    table.insert(snippets, snip)
  end

  ls.add_snippets("lspt", snippets)
  registered = true
end

return M
