-- lua/lspt/server.lua
-- Auto-install do language server llutti/vscode-language-lsp.
--
-- Estratégia:
--   1. git clone (raso) do repo em config.server.install_dir
--   2. npm install
--   3. npm run build   (na raiz do repo; o script raiz delega ao pacote extension)
--   4. Resolve o caminho do server.js
--
-- A função `resolve()` retorna o array `cmd` pronto pro vim.lsp.start ou nil
-- se o server não estiver disponível.

local M = {}

local config = require("lspt.config")
local uv = vim.uv or vim.loop

local function notify(msg, level)
  vim.notify("[lspt] " .. msg, level or vim.log.levels.INFO)
end

local function path_exists(p)
  return uv.fs_stat(p) ~= nil
end

---@return string server_js  caminho absoluto pro dist/server.js
function M.server_path()
  local cfg = config.get().server
  return vim.fs.joinpath(cfg.install_dir, "packages/extension/dist/server.js")
end

---@return boolean
function M.is_installed()
  local server_js = M.server_path()
  return server_js ~= nil and path_exists(server_js)
end

local function run(cmd, cwd, on_done)
  local stdout = {}
  local stderr = {}
  local job = vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data) vim.list_extend(stdout, data or {}) end,
    on_stderr = function(_, data) vim.list_extend(stderr, data or {}) end,
    on_exit   = function(_, code)
      on_done(code, stdout, stderr)
    end,
  })
  if job <= 0 then
    on_done(-1, {}, { "falha ao spawnar: " .. table.concat(cmd, " ") })
  end
end

---@param on_done fun(ok: boolean, err: string|nil)
function M.install(on_done)
  local cfg = config.get().server
  local dir = cfg.install_dir

  -- 0) checa dependências externas
  for _, bin in ipairs({ "git", "npm", cfg.node }) do
    if vim.fn.executable(bin) == 0 then
      on_done(false, "'" .. bin .. "' não encontrado no PATH")
      return
    end
  end

  vim.fn.mkdir(vim.fn.fnamemodify(dir, ":h"), "p")

  -- 1) clone (se ainda não foi clonado) ou pull (para atualizar in-place)
  local function step_clone(next)
    if path_exists(vim.fs.joinpath(dir, ".git")) then
      notify("repo já existe, atualizando via git pull ...")
      run({ "git", "-C", dir, "pull", "--ff-only" }, nil, function(code, _, err)
        if code ~= 0 then
          on_done(false, "git pull falhou: " .. table.concat(vim.tbl_filter(function(l) return l ~= "" end, err), "\n"))
          return
        end
        next()
      end)
      return
    end

    notify("clonando " .. cfg.repo .. " ...")
    local cmd = { "git", "clone", "--depth", "1" }
    if cfg.branch then
      table.insert(cmd, "--branch")
      table.insert(cmd, cfg.branch)
    end
    table.insert(cmd, cfg.repo)
    table.insert(cmd, dir)

    run(cmd, nil, function(code, _, err)
      if code ~= 0 then
        on_done(false, "git clone falhou: " .. table.concat(vim.tbl_filter(function(l) return l ~= "" end, err), "\n"))
        return
      end
      next()
    end)
  end

  local function step_npm_install(next)
    notify("rodando npm install (pode demorar alguns minutos) ...")
    run({ "npm", "install" }, dir, function(code, _, err)
      if code ~= 0 then
        on_done(false, "npm install falhou: " .. table.concat(vim.tbl_filter(function(l) return l ~= "" end, err), "\n"))
        return
      end
      next()
    end)
  end

  local function step_build(next)
    notify("buildando o language server ...")
    run({ "npm", "run", "build" }, dir, function(code, _, err)
      if code ~= 0 then
        on_done(false, "npm run build falhou: " .. table.concat(vim.tbl_filter(function(l) return l ~= "" end, err), "\n"))
        return
      end
      next()
    end)
  end

  step_clone(function()
    step_npm_install(function()
      step_build(function()
        if M.is_installed() then
          notify("server instalado com sucesso em " .. M.server_path())
          on_done(true)
        else
          on_done(false, "build aparentemente OK mas dist/server.js não encontrado")
        end
      end)
    end)
  end)
end

---@return string[]|nil cmd argv pronto para vim.lsp.start
function M.resolve_cmd()
  local cfg = config.get().server

  -- override manual: caminho explícito tem prioridade total
  if cfg.command and #cfg.command > 0 then
    return cfg.command
  end

  if not M.is_installed() then
    return nil
  end

  return { cfg.node, M.server_path(), "--stdio" }
end

return M
