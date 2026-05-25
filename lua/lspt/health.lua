-- lua/lspt/health.lua
-- :checkhealth lspt

local M = {}

local h = vim.health or require("health")
local start = h.start or h.report_start
local ok = h.ok or h.report_ok
local warn = h.warn or h.report_warn
local error_ = h.error or h.report_error
local info = h.info or h.report_info

function M.check()
	start("lspt.nvim")

	-- Neovim version
	if vim.fn.has("nvim-0.10") == 1 then
		ok("Neovim >= 0.10")
	else
		warn("recomendado Neovim 0.10+ para LSP nativo confiável")
	end

	-- Binários externos
	for _, bin in ipairs({ "git", "npm", "node" }) do
		if vim.fn.executable(bin) == 1 then
			ok(bin .. ": encontrado (" .. vim.fn.exepath(bin) .. ")")
		else
			error_(bin .. ": NÃO encontrado no PATH (necessário para auto-install do server)")
		end
	end

	-- Versão do Node
	if vim.fn.executable("node") == 1 then
		local node_ver = vim.fn.system({ "node", "--version" }):gsub("%s+$", "")
		info("node version: " .. node_ver)
	end

	-- LuaSnip
	if pcall(require, "luasnip") then
		ok("LuaSnip presente — snippets disponíveis")
	else
		warn("LuaSnip não encontrado — snippets não serão registrados")
	end

	-- cmp_nvim_lsp (opcional)
	if pcall(require, "cmp_nvim_lsp") then
		ok("cmp_nvim_lsp presente — capacidades de completion ampliadas")
	else
		info("cmp_nvim_lsp não encontrado (opcional)")
	end

	-- Server instalado?
	local server = require("lspt.server")
	if server.is_installed() then
		ok("language server instalado em " .. server.server_path())
	else
		local cfg = require("lspt.config").get()
		if cfg.server.command then
			info("server.command override configurado: " .. table.concat(cfg.server.command, " "))
		else
			warn("language server não instalado. Rode :LsptInstallServer")
		end
	end

	-- Filetype registrado
	local ft = vim.filetype.match({ filename = "exemplo.lspt" })
	if ft == "lspt" then
		ok("filetype 'lspt' registrado para .lspt")
	else
		error_("filetype 'lspt' não registrado (esperava 'lspt', obteve '" .. tostring(ft) .. "')")
	end
end

return M
