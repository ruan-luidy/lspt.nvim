vim.cmd("edit C:/Users/Usurio/source/repos/lspt.nvim/test_sample.lspt")
vim.cmd("sleep 800m")
local out = {}
table.insert(out, "filetype=" .. vim.bo.filetype)
table.insert(out, "commentstring=" .. vim.bo.commentstring)
table.insert(out, "foldmethod=" .. vim.wo.foldmethod)
table.insert(out, "indentexpr=" .. vim.bo.indentexpr)
table.insert(out, "current_syntax=" .. tostring(vim.b.current_syntax))
table.insert(out, "match_words set=" .. tostring(vim.b.match_words ~= nil))
table.insert(out, "iskeyword=" .. vim.bo.iskeyword)
table.insert(out, "shiftwidth=" .. vim.bo.shiftwidth)

local cl = vim.lsp.get_clients({ name = "lspt" })
table.insert(out, "lspt LSP clients=" .. #cl)

local cmds = vim.api.nvim_get_commands({})
for _, c in ipairs({ "LsptInstallServer", "LsptHealth", "LsptRestart", "LsptInfo",
                     "LsptContextSettings", "LsptQuickFixConfirmName" }) do
  table.insert(out, c .. " exists=" .. tostring(cmds[c] ~= nil))
end

-- testa folding
local fold = require("lspt.folding")
table.insert(out, "fold@line1 (Bloco)=" .. fold.expr(1))
table.insert(out, "fold@line9 (Funcao Inicio)=" .. fold.expr(9))
table.insert(out, "fold@line22 (Fim;)=" .. fold.expr(22))
table.insert(out, "fold@line24 (FimBloco)=" .. fold.expr(24))

-- testa indent
table.insert(out, "indent line 11 ('Inicio' apos func)=" .. vim.fn.LsptIndent(11))
table.insert(out, "indent line 15 (Fim apos ExecSql)=" .. vim.fn.LsptIndent(15))

for _, s in ipairs(out) do print(s) end
