-- plugin/lspt.lua
-- Carrega comandos básicos mesmo se o usuário esquecer de chamar setup().
-- Isso permite rodar :LsptInstallServer e :LsptHealth direto do "out-of-the-box".

if vim.g.loaded_lspt_nvim then
  return
end
vim.g.loaded_lspt_nvim = true

-- Registra commands base (idempotente)
require("lspt.commands").register()

-- Se o usuário NÃO chamou setup(), ainda assim queremos que abrir um .lspt
-- inicie o LSP. O ftplugin já cuida disso, mas o autocmd aqui garante o caso
-- de :setfiletype lspt em buffer scratch.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lspt",
  group   = vim.api.nvim_create_augroup("lspt-default-attach", { clear = true }),
  callback = function(args)
    local ok, lsp = pcall(require, "lspt.lsp")
    if ok then lsp.try_start(args.buf) end
  end,
})
