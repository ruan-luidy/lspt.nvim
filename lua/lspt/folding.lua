-- lua/lspt/folding.lua
-- Folding expr para arquivos LSPT.
--
-- Estratégia: marcadores explícitos de bloco no estilo do plugin VSCode
--   @-- Bloco 'nome' --@
--   ...
--   @-- FimBloco 'nome' --@
--
-- Fallback: blocos Inicio/Fim contam para indent-based fallback quando
-- o usuário preferir.

local M = {}

local fold_start = vim.regex([[\v^\s*\@--\s*\#?(bloco|Bloco)>(\s\'.*\')?\s*--\@]])
local fold_end = vim.regex([[\v^\s*\@--\s*\#?(fimbloco|FimBloco|Fimbloco)>(\s\'.*\')?\s*--\@]])
local inicio_re = vim.regex([[\v\c<inicio>\s*$]])
local fim_re = vim.regex([[\v\c^\s*<fim>]])

local function get_line(lnum)
	return vim.fn.getline(lnum)
end

function M.expr(lnum)
	local line = get_line(lnum)
	if fold_start:match_str(line) then
		return "a1"
	end
	if fold_end:match_str(line) then
		return "s1"
	end
	if inicio_re:match_str(line) then
		return "a1"
	end
	if fim_re:match_str(line) then
		return "s1"
	end
	return "="
end

function M.text()
	local lnum = vim.v.foldstart
	local line = get_line(lnum)
	local count = vim.v.foldend - vim.v.foldstart + 1
	local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
	return string.format("  %s  [%d linhas]", trimmed, count)
end

return M
