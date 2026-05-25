-- lua/lspt/pairs.lua
-- Auto-pair opcional para `inicio` -> `fim;` e `@--` -> `--@`.
--
-- Padrão: desabilitado. Habilite com:
--   require("lspt").setup({ pairs = { enabled = true } })
--
-- Strategy: usa expr mapping em insert mode no escopo do buffer.

local M = {}

local function feed(keys)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, false, true),
    "n",
    false
  )
end

-- Expande "inicio<CR>" para
--   inicio
--   |    <-- cursor aqui, indentado um nível
--   fim;
local function expand_inicio()
  local line = vim.api.nvim_get_current_line()
  local col  = vim.api.nvim_win_get_cursor(0)[2]

  -- só dispara se o cursor está logo após "inicio" no fim da linha (ignorando trailing spaces)
  local before = line:sub(1, col):lower()
  local after  = line:sub(col + 1)

  if not before:match("%f[%w]inicio%s*$") then return false end
  if after:match("%S") then return false end

  local lnum   = vim.api.nvim_win_get_cursor(0)[1]
  local indent = line:match("^%s*") or ""
  local sw     = string.rep(" ", vim.bo.shiftwidth)

  vim.api.nvim_buf_set_lines(0, lnum, lnum, false, {
    indent .. sw,
    indent .. "Fim;",
  })
  vim.api.nvim_win_set_cursor(0, { lnum + 1, #(indent .. sw) })
  return true
end

function M.attach(bufnr)
  bufnr = bufnr or 0

  vim.keymap.set("i", "<CR>", function()
    -- Não interfere com confirmação de completion (nvim-cmp, built-in popup, etc.)
    if vim.fn.pumvisible() == 1 then
      return "<CR>"
    end
    if expand_inicio() then
      return ""
    end
    return "<CR>"
  end, { buffer = bufnr, expr = true, replace_keycodes = true,
        desc = "[lspt] expande inicio/fim" })

  -- @-- ... --@ (cursor no meio)
  vim.keymap.set("i", "@--", function()
    feed("@--  --@<Left><Left><Left><Left>")
  end, { buffer = bufnr, desc = "[lspt] auto-pair comentário" })
end

return M
