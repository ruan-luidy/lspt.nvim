-- lua/lspt/lsp.lua
-- Integração do language server com o cliente LSP nativo do Neovim.

local M = {}

local config = require("lspt.config")
local server = require("lspt.server")

local function notify(msg, level)
  vim.notify("[lspt] " .. msg, level or vim.log.levels.INFO)
end

---@return string root_dir
local function find_root(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    return vim.uv.cwd()
  end

  local dir = vim.fs.dirname(fname)
  -- Busca marcadores em ordem de preferência: .git tem prioridade sobre .vscode
  for _, marker in ipairs({ ".git", ".vscode" }) do
    local found = vim.fs.find(marker, { upward = true, path = dir })[1]
    if found then
      return vim.fs.dirname(found)
    end
  end
  return dir
end

local function build_capabilities()
  local cfg = config.get()
  if cfg.capabilities then
    return cfg.capabilities
  end

  local caps = vim.lsp.protocol.make_client_capabilities()
  if cfg.cmp then
    -- blink.cmp (NvChad v2.5+) toma precedência se ambos existirem
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink and blink.get_lsp_capabilities then
      caps = blink.get_lsp_capabilities(caps)
    else
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        caps = cmp_lsp.default_capabilities(caps)
      end
    end
  end
  return caps
end

local function default_on_attach(_, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "[lspt] " .. desc })
  end

  map("n", "gd", vim.lsp.buf.definition,      "Ir para definição")
  map("n", "gr", vim.lsp.buf.references,      "Referências")
  map("n", "K",  vim.lsp.buf.hover,           "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename,  "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format")
  map("i", "<C-s>", vim.lsp.buf.signature_help, "Signature help")
end

local notified_missing = false

---@param bufnr integer
function M.try_start(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "lspt" then
    return
  end

  local cmd = server.resolve_cmd()
  if not cmd then
    if not notified_missing then
      notified_missing = true
      local cfg = config.get().server
      if cfg.auto_install then
        notify("language server não instalado. Rode :LsptInstallServer para instalar automaticamente.",
          vim.log.levels.WARN)
      end
    end
    return
  end
  notified_missing = false

  local cfg = config.get()
  local root_dir = find_root(bufnr)

  -- vim.lsp.start já reusa internamente por (name, cmd, root_dir):
  -- não cria duplicado, só dá buf_attach.
  vim.lsp.start({
    name = "lspt",
    cmd  = cmd,
    root_dir = root_dir,
    capabilities = build_capabilities(),
    workspace_folders = {
      { uri = vim.uri_from_fname(root_dir), name = vim.fs.basename(root_dir) },
    },
    init_options = {
      vscodeVersion     = "neovim/" .. tostring(vim.version()),
      globalStoragePath = vim.fs.joinpath(vim.fn.stdpath("data"), "lspt-global"),
    },
    settings = {
      lsp = cfg.server_settings,
    },
    handlers = {
      ["lsp/log"] = function(_, params)
        if params and params.message then
          local level = params.level == "error" and vim.log.levels.ERROR
            or params.level == "warn" and vim.log.levels.WARN
            or vim.log.levels.DEBUG
          notify("server: " .. params.message, level)
        end
      end,
    },
    on_exit = function(code, signal)
      if code ~= 0 then
        vim.schedule(function()
          notify(
            string.format("server encerrou inesperadamente (code=%d, signal=%d)", code, signal),
            vim.log.levels.WARN
          )
        end)
      end
    end,
    on_attach = function(client, buf)
      -- Notifica o server sobre o documento ativo (melhora prioridade de diagnósticos)
      local function notify_active()
        local fname = vim.api.nvim_buf_get_name(buf)
        if fname ~= "" then
          client.notify("lsp/activeDocumentChanged", { uri = vim.uri_from_fname(fname) })
        end
      end
      notify_active()
      vim.api.nvim_create_autocmd("BufEnter", {
        buffer = buf,
        group  = vim.api.nvim_create_augroup("lspt-active-doc-" .. buf, { clear = true }),
        callback = notify_active,
      })

      if cfg.on_attach then
        cfg.on_attach(client, buf)
      else
        default_on_attach(client, buf)
      end
    end,
  })
end

function M.stop_all()
  for _, client in ipairs(vim.lsp.get_clients({ name = "lspt" })) do
    client.stop()
  end
end

function M.restart()
  M.stop_all()
  vim.defer_fn(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "lspt" then
        M.try_start(buf)
      end
    end
  end, 200)
end

return M
