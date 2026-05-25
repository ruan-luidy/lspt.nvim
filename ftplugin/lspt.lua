-- ftplugin/lspt.lua
-- Equivalente ao lsp-configuration.json do plugin VSCode.

if vim.b.did_ftplugin_lspt then
  return
end
vim.b.did_ftplugin_lspt = true

-- ---------------------------------------------------------------------------
-- Comentários
-- O VSCode trata `@-- ... --@` como blockComment. Mapeamos pra commentstring
-- do Neovim. Compatível com vim-commentary, mini.comment e Comment.nvim.
-- ---------------------------------------------------------------------------
vim.bo.commentstring = "@-- %s --@"
vim.bo.comments      = "s:@--,m: ,e:--@"

-- ---------------------------------------------------------------------------
-- Brackets / matchpairs
-- 'matchpairs' só aceita caracteres únicos, então inicio/fim ficam por
-- conta do matchit (carregado pelas regras match_words abaixo).
-- ---------------------------------------------------------------------------
vim.bo.matchpairs = "(:),{:},[:]"

vim.b.match_words = table.concat({
  [[\<\c\(inicio\)\>:\<\c\(fim\)\>]],
  [[\<\c\(se\)\>:\<\c\(senao\)\>:\<\c\(fim\)\>]],
  [[\<\c\(enquanto\)\>:\<\c\(fim\)\>]],
  [[\<\c\(para\)\>:\<\c\(fim\)\>]],
  [[\<\c\(funcao\)\>:\<\c\(retorna\)\>:\<\c\(fim\)\>]],
}, ",")
vim.b.match_ignorecase = 1

-- ---------------------------------------------------------------------------
-- Indentação (defaults; o usuário pode sobrescrever no after/ftplugin)
-- ---------------------------------------------------------------------------
vim.bo.expandtab   = true
vim.bo.shiftwidth  = 2
vim.bo.softtabstop = 2
vim.bo.tabstop     = 2
vim.bo.smartindent = false

-- (autoindent + indentexpr ficam em indent/lspt.vim)

-- ---------------------------------------------------------------------------
-- Folding (window-local)
-- ---------------------------------------------------------------------------
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr   = "v:lua.require'lspt.folding'.expr(v:lnum)"
vim.opt_local.foldtext   = "v:lua.require'lspt.folding'.text()"

-- ---------------------------------------------------------------------------
-- Iskeyword - permite identificadores como SQL_AbrirCursor (sublinhado)
-- ---------------------------------------------------------------------------
vim.bo.iskeyword = "@,48-57,_,192-255"

-- ---------------------------------------------------------------------------
-- Auto-pair (opt-in)
-- ---------------------------------------------------------------------------
do
  local ok, cfg = pcall(require, "lspt.config")
  if ok and cfg.get().pairs.enabled then
    require("lspt.pairs").attach(0)
  end
end

-- ---------------------------------------------------------------------------
-- Snippets (LuaSnip; idempotente)
-- ---------------------------------------------------------------------------
do
  local ok, snip = pcall(require, "lspt.snippets")
  if ok then snip.setup_buffer() end
end

-- ---------------------------------------------------------------------------
-- (LSP attach é tratado exclusivamente pelo autocmd FileType em
-- plugin/lspt.lua — incluindo :setfiletype lspt em buffer scratch, que
-- dispara o evento FileType.)
-- ---------------------------------------------------------------------------
-- undo_ftplugin: necessário para :setfiletype trocar para outro ft.
-- ---------------------------------------------------------------------------
vim.b.undo_ftplugin = table.concat({
  "setlocal commentstring< comments< matchpairs< iskeyword<",
  "setlocal expandtab< shiftwidth< softtabstop< tabstop< smartindent<",
  "setlocal foldmethod< foldexpr< foldtext<",
  "unlet! b:match_words b:match_ignorecase b:did_ftplugin_lspt",
}, " | ")
