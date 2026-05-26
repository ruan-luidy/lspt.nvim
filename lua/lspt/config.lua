-- lua/lspt/config.lua
-- Configuração do plugin lspt.nvim.
--
-- As chaves de `server_settings` espelham EXATAMENTE as do plugin VSCode
-- (https://github.com/llutti/vscode-language-lsp), porque o language server
-- as recebe via `workspace/configuration` com a seção "lsp".

local M = {}

---@class LsptUserConfig
---@field server LsptServerConfig
---@field server_settings table   -- repassado ao server via workspace/configuration
---@field pairs LsptPairsConfig
---@field cmp boolean
---@field on_attach fun(client, bufnr)|nil
---@field capabilities table|nil

---@class LsptServerConfig
---@field auto_install boolean   -- se true, baixa e builda o server do llutti
---@field command string[]|nil   -- override manual: ex { "node", "/caminho/server.js", "--stdio" }
---@field install_dir string|nil -- onde o auto-install vai clonar
---@field repo string            -- url do git para auto-install
---@field branch string|nil
---@field node string            -- binário node (PATH ou absoluto)

---@class LsptPairsConfig
---@field enabled boolean

local defaults = {
	server = {
		auto_install = true,
		command = nil,
		install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "lspt-server"),
		repo = "https://github.com/llutti/vscode-language-lsp.git",
		branch = nil, -- nil = default branch
		node = "node",
	},

	-- Settings repassadas ao server LSP. Veja docs do plugin VSCode.
	server_settings = {
		contexts = {}, -- ver lsp.contexts no README
		fallback = { defaultSystem = vim.NIL },
		format = {
			enabled = true,
			indentSize = 2,
			useTabs = false,
			maxParamsPerLine = 4,
			embeddedSql = {
				enabled = false,
				dialect = "sql", -- "sql" | "oracle" | "sqlserver"
			},
		},
		semantic = {
			embeddedSqlHighlight = { enabled = false },
		},
		refactor = {
			defaultBlockStyle = "inicioFim", -- "inicioFim" | "braces"
		},
		diagnostics = {
			ignoreIds = {},
		},
		debug = {
			enabled = false,
			path = "",
		},
	},

	pairs = {
		enabled = false, -- inicio/fim auto-pair (opt-in)
	},

	cmp = true, -- integra com cmp-nvim-lsp se disponível
	on_attach = nil,
	capabilities = nil,
}

local current = vim.deepcopy(defaults)

function M.setup(user)
	user = user or {}
	current = vim.tbl_deep_extend("force", defaults, user)
	return current
end

function M.get()
	return current
end

function M.defaults()
	return vim.deepcopy(defaults)
end

return M
