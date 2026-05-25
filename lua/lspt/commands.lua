-- lua/lspt/commands.lua
-- User commands do lspt.nvim. Espelham os comandos do plugin VSCode original.

local M = {}

local function get_client()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "lspt" })
  return clients[1]
end

local function exec(cmd, args)
  local client = get_client()
  if not client then
    vim.notify("[lspt] nenhum client LSPT ativo neste buffer", vim.log.levels.WARN)
    return
  end
  client.request("workspace/executeCommand", {
    command = cmd,
    arguments = args or {},
  }, function(err, result)
    if err then
      vim.notify("[lspt] erro: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end
    if result then
      vim.notify("[lspt] " .. vim.inspect(result))
    end
  end)
end

local function ensure(tbl, key)
  tbl[key] = tbl[key] or {}
  return tbl[key]
end

local function update_setting(path, value)
  local cfg = require("lspt.config").get()
  cfg.server_settings = cfg.server_settings or {}
  local node = cfg.server_settings
  for i = 1, #path - 1 do
    node = ensure(node, path[i])
  end
  node[path[#path]] = value

  -- notifica todos os clients
  for _, client in ipairs(vim.lsp.get_clients({ name = "lspt" })) do
    client.notify("workspace/didChangeConfiguration", {
      settings = { lsp = cfg.server_settings },
    })
  end
end

function M.register()
  local create = vim.api.nvim_create_user_command

  -- ----- Server lifecycle -----
  create("LsptInstallServer", function()
    require("lspt.server").install(function(ok, err)
      if ok then
        vim.notify("[lspt] server instalado. Reabra um arquivo .lspt.")
      else
        vim.notify("[lspt] falha na instalação: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end, { desc = "Clona e builda o language server" })

  create("LsptRestart", function()
    require("lspt.lsp").restart()
  end, { desc = "Reinicia o cliente LSP" })

  create("LsptStop", function()
    require("lspt.lsp").stop_all()
  end, { desc = "Para todos os clients LSP" })

  create("LsptInfo", function()
    local cfg = require("lspt.config").get()
    local srv = require("lspt.server")
    local clients = vim.lsp.get_clients({ name = "lspt" })
    print("---- lspt.nvim ----")
    print("server instalado: " .. tostring(srv.is_installed()))
    print("server path:      " .. tostring(srv.server_path()))
    print("auto_install:     " .. tostring(cfg.server.auto_install))
    print("clients ativos:   " .. #clients)
    for _, c in ipairs(clients) do
      print("  - id=" .. c.id .. " root=" .. (c.config.root_dir or "?"))
    end
  end, { desc = "Mostra status do lspt.nvim" })

  -- ----- Contextos (equivalente a LSP: Criar/Editar/Remover Contexto) -----
  create("LsptContextCreate", function()  exec("lsp.contexts.create")  end,
    { desc = "Cria um novo contexto LSP" })
  create("LsptContextEdit", function()    exec("lsp.contexts.edit")    end,
    { desc = "Edita um contexto LSP" })
  create("LsptContextDelete", function()  exec("lsp.contexts.delete")  end,
    { desc = "Remove um contexto LSP" })
  create("LsptContextValidate", function() exec("lsp.contexts.validate") end,
    { desc = "Valida os contextos LSP" })
  create("LsptContextSettings", function() exec("lsp.contexts.openSettings") end,
    { desc = "Abre configurações de contextos LSP" })

  -- ----- Quick Fix (server-side) -----
  create("LsptQuickFixConfirmName", function() exec("lsp.quickFix.confirmName") end,
    { desc = "Aplica Quick Fix: confirmar nome" })
  create("LsptQuickFixEditPlan", function() exec("lsp.quickFix.applyEditPlan") end,
    { desc = "Aplica Quick Fix: plano de edição" })

  -- ----- Diagnósticos -----
  local function ignored_ids()
    local cfg = require("lspt.config").get()
    local diag = cfg.server_settings and cfg.server_settings.diagnostics
    return (diag and diag.ignoreIds) or {}
  end

  create("LsptIgnoreId", function(opts)
    if opts.args == "" then
      exec("lsp.diagnostics.ignoreId")
    else
      local list = vim.deepcopy(ignored_ids())
      if not vim.tbl_contains(list, opts.args) then
        table.insert(list, opts.args)
        update_setting({ "diagnostics", "ignoreIds" }, list)
        vim.notify("[lspt] ignorando diagnóstico: " .. opts.args)
      end
    end
  end, { nargs = "?", desc = "Ignora um ID de diagnóstico" })

  create("LsptUnignoreId", function(opts)
    if opts.args == "" then
      exec("lsp.diagnostics.unignoreId")
    else
      local out = {}
      for _, id in ipairs(ignored_ids()) do
        if id ~= opts.args then table.insert(out, id) end
      end
      update_setting({ "diagnostics", "ignoreIds" }, out)
      vim.notify("[lspt] não ignora mais: " .. opts.args)
    end
  end, { nargs = "?", desc = "Para de ignorar um ID de diagnóstico" })

  create("LsptListIgnoredIds", function()
    local list = ignored_ids()
    if #list == 0 then
      print("[lspt] nenhum ID ignorado")
    else
      print("[lspt] IDs ignorados:")
      for _, id in ipairs(list) do print("  - " .. id) end
    end
  end, { desc = "Lista IDs de diagnóstico ignorados" })

  create("LsptClearIgnoredIds", function()
    update_setting({ "diagnostics", "ignoreIds" }, {})
    vim.notify("[lspt] lista de IDs ignorados limpa (workspace)")
  end, { desc = "Limpa todos os IDs ignorados (workspace)" })

  -- Equivalente ao "Limpar IDs Ignorados (Usuário)" do VSCode original — server-side
  create("LsptClearIgnoredIdsUser", function() exec("lsp.diagnostics.clearIgnoredIdsUser") end,
    { desc = "Limpa IDs ignorados a nível de usuário (server-side)" })

  -- ----- Fallback System -----
  create("LsptSelectSystem", function(opts)
    if opts.args == "" then
      exec("lsp.fallback.selectSystem")
    else
      update_setting({ "fallback", "defaultSystem" }, opts.args)
      vim.notify("[lspt] sistema padrão: " .. opts.args)
    end
  end, {
    nargs = "?",
    complete = function() return { "HCM", "ACESSO", "ERP" } end,
    desc = "Seleciona o sistema fallback (HCM | ACESSO | ERP)",
  })

  -- ----- Format toggle -----
  create("LsptFormatToggle", function()
    local cfg = require("lspt.config").get()
    local fmt = cfg.server_settings and cfg.server_settings.format
    local cur = fmt and fmt.enabled
    if cur == nil then cur = true end
    update_setting({ "format", "enabled" }, not cur)
    vim.notify("[lspt] format.enabled = " .. tostring(not cur))
  end, { desc = "Liga/desliga o formatter" })

  -- ----- Snippets -----
  create("LsptSnippets", function()
    local list = require("lspt.snippets").list()
    print(string.format("[lspt] %d snippets disponíveis:", #list))
    for _, s in ipairs(list) do
      print(string.format("  %-25s %s", s.prefix, s.description or ""))
    end
  end, { desc = "Lista snippets disponíveis" })

  -- ----- Health -----
  create("LsptHealth", function()
    vim.cmd("checkhealth lspt")
  end, { desc = "Roda checkhealth do lspt.nvim" })
end

return M
