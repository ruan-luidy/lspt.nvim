" syntax/lspt.vim
" Syntax highlight para a Linguagem Senior de Programação (LSP).
" Portado de: https://github.com/llutti/vscode-language-lsp
"             packages/extension/syntaxes/lsp.tmLanguage.json
"
" Linguagem case-insensitive: `syntax case ignore` no topo.
"
" Notas de implementação:
"   * `syntax keyword` tem precedência sobre `syntax match`/`region`, então
"     algumas keywords usam `nextgroup` pra direcionar o engine ao próximo token.
"   * `lsptFunctionCall` EXCLUI explicitamente as funções SQL (ExecSql etc.) para
"     não consumir o nome antes da região `lsptEmbeddedSql` ancorar.

if exists("b:current_syntax")
  finish
endif

let s:keepcpo = &cpo
set cpo&vim

syntax case ignore

" ============================================================================
" Comentários
" ============================================================================
syntax region lsptComment      start=/@--/ end=/--@/ contains=lsptCommentTodo,@Spell keepend
syntax region lsptBlockComment start=/\/\*/ end=/\*\// contains=lsptCommentTodo,@Spell keepend
syntax keyword lsptCommentTodo TODO FIXME XXX NOTE HACK contained
syntax match  lsptBlocoPragma /@--\s*\%(Bloco\|FimBloco\|fimbloco\)\>\s*'[^']*'\s*--@/
syntax match  lsptSqlPragma   /^\s*@lsp-sql-\%(consulta\|fragmento\)@\s*$/

" ============================================================================
" SQL embutido (DEVE vir antes das strings comuns)
" ============================================================================
syntax cluster lsptSqlContents contains=lsptSqlBindVar,lsptSqlKeyword,lsptStringEscape

syntax region lsptEmbeddedSql matchgroup=lsptSqlFunc
      \ start=/\<ExecSql\>\s*(\s*"/
      \ skip=/\\"/
      \ end=/"/
      \ contains=@lsptSqlContents keepend

syntax region lsptEmbeddedSql matchgroup=lsptSqlFunc
      \ start=/\<ExecSQLEx\>\s*(\s*"/
      \ skip=/\\"/
      \ end=/"/
      \ contains=@lsptSqlContents keepend

syntax region lsptEmbeddedSql matchgroup=lsptSqlFunc
      \ start=/\<SQL_DefinirComando\>\s*([^,]\+,\s*"/
      \ skip=/\\"/
      \ end=/"/
      \ contains=@lsptSqlContents keepend

syntax match lsptSqlBindVar /:\h\w*/ contained

syntax keyword lsptSqlKeyword contained
      \ SELECT FROM WHERE AND OR NOT IN IS NULL ORDER BY GROUP HAVING
      \ INSERT INTO UPDATE SET DELETE VALUES JOIN LEFT RIGHT INNER OUTER
      \ ON AS DISTINCT UNION ALL CASE WHEN THEN ELSE END BETWEEN LIKE
      \ COUNT SUM AVG MIN MAX

" ============================================================================
" Strings comuns
" ============================================================================
syntax match  lsptStringEscape /\\./ contained
syntax region lsptString start=/"/ skip=/\\"/ end=/"/ contains=lsptStringEscape,@Spell
syntax region lsptStringSingle start=/'/ skip=/\\'/ end=/'/ contains=lsptStringEscape

" ============================================================================
" mensagem(retorna|erro|refaz)
" ============================================================================
syntax match lsptMensagemCall /\<mensagem\>\s*(\s*\%(retorna\|erro\|refaz\)\>/
      \ contains=lsptMensagemKw,lsptMensagemMode
syntax keyword lsptMensagemKw   mensagem contained
syntax keyword lsptMensagemMode retorna erro refaz contained

" ============================================================================
" Palavras-chave
" ============================================================================
" `definir` usa nextgroup para que o tipo seguinte vire lsptDefinirType
" e o identificador depois do tipo vire lsptDefinirIdent.
syntax keyword lsptKeyword definir nextgroup=lsptDefinirType skipwhite skipnl
syntax keyword lsptKeyword
      \ end fim inicio regra vaparacampo vaparapagina
      \ retorna erro iniciartransacao desfazertransacao finalizartransacao

" `funcao` também tem identificador esperado após
syntax keyword lsptKeyword funcao nextgroup=lsptFuncaoIdent skipwhite skipnl

" `chamarfuncao` idem
syntax keyword lsptKeyword chamarfuncao nextgroup=lsptChamarFuncaoIdent skipwhite skipnl

syntax keyword lsptControl
      \ continue enquanto para se senao pare vapara

syntax keyword lsptOperator e ou

" Tipos (standalone — quando não estão no "definir <tipo>")
syntax keyword lsptType alfa cursor data lista numero tabela
" Nota: `funcao` aparece em lsptKeyword acima por causa do nextgroup.

syntax keyword lsptBoolean cverdadeiro cfalso

" Tokens contained, alimentados via nextgroup:
syntax match lsptDefinirType /\<\%(alfa\|cursor\|data\|lista\|numero\|tabela\|funcao\)\>/
      \ contained nextgroup=lsptDefinirIdent skipwhite skipnl
syntax match lsptDefinirIdent /\<\h\w*\>/ contained
syntax match lsptFuncaoIdent  /\<\h\w*\>/ contained
syntax match lsptChamarFuncaoIdent /\<\h\w*\>/ contained

" Parametros em assinaturas: ( alfa nome ) ou (, numero end nome )
syntax match lsptParamIdent /[,(]\s*\<\%(alfa\|numero\|data\)\>\s\+\%(\<end\>\s\+\)\?\zs\<\h\w*\>/

" ============================================================================
" Métodos de Cursor/Lista (.Primeiro, .Proximo, etc.)
" ============================================================================
syntax match lsptMethod /\.\zs\<\%(abrircursor\|achou\|fecharcursor\|naoachou\|proximo\|sql\|usaabrangencia\|adicionar\|adicionarcampo\|anterior\|cancelar\|chave\|definircampos\|editar\|editarchave\|efetivarcampos\|excluir\|fda\|gravar\|ida\|inserir\|limpar\|numreg\|primeiro\|qtdregistros\|setanumreg\|setarchave\|ultimo\|vaiparachave\)\>/

" Região de SQL embutido via método .SQL("...") — definida APÓS lsptMethod para
" ter prioridade sobre ele quando seguida de uma string (cursor.SQL("SELECT ..."))
syntax region lsptEmbeddedSql matchgroup=lsptSqlFunc
      \ start=/\.\<SQL\>\s*(\s*"/
      \ skip=/\\"/
      \ end=/"/
      \ contains=@lsptSqlContents keepend

" ============================================================================
" Chamadas de função genéricas
" Exclusões:
"   * ExecSql/ExecSQLEx/SQL_DefinirComando — capturados por lsptEmbeddedSql
"   * Identificadores precedidos por `.` — capturados por lsptMethod
" ============================================================================
syntax match lsptFunctionCall /\%(\.\)\@<!\<\%(ExecSql\|ExecSQLEx\|SQL_DefinirComando\)\@!\h\w*\>\ze\s*(/

" ============================================================================
" Números
" ============================================================================
syntax match lsptNumber /\<\d\+\>/
syntax match lsptNumber /\<\d*\.\d\+\%([eE][-+]\?\d\+\)\?\>/

" ============================================================================
" Operadores e pontuação
" ============================================================================
syntax match lsptOperatorSym /<=\|>=\|<>\|!=\|[+\-*/=<>!]/
syntax match lsptPunctuation /[;,()[\]{}]/

" ============================================================================
" Highlight links — usa grupos @treesitter para compatibilidade com temas
" modernos (catppuccin, tokyonight, etc.). Cada @grupo tem fallback para o
" grupo Vim clássico, então funciona em qualquer versão >= 0.10.
" ============================================================================
highlight default link lsptComment        @comment
highlight default link lsptBlockComment   @comment
highlight default link lsptCommentTodo    @comment.note
highlight default link lsptBlocoPragma    @attribute
highlight default link lsptSqlPragma      @attribute

highlight default link lsptString         @string
highlight default link lsptStringSingle   @string
highlight default link lsptStringEscape   @string.escape

highlight default link lsptEmbeddedSql    @string.special
highlight default link lsptSqlFunc        @function.call
highlight default link lsptSqlBindVar     @variable.parameter
highlight default link lsptSqlKeyword     @keyword

highlight default link lsptKeyword        @keyword
highlight default link lsptControl        @keyword.conditional
highlight default link lsptOperator       @keyword.operator
highlight default link lsptOperatorSym    @operator
highlight default link lsptType           @type.builtin
highlight default link lsptDefinirType    @type.builtin
highlight default link lsptBoolean        @boolean
highlight default link lsptNumber         @number
highlight default link lsptPunctuation    @punctuation.delimiter

highlight default link lsptMensagemKw     @keyword
highlight default link lsptMensagemMode   @string.special

highlight default link lsptDefinirIdent       @variable
highlight default link lsptFuncaoIdent        @function
highlight default link lsptChamarFuncaoIdent  @function.call
highlight default link lsptParamIdent         @variable.parameter

highlight default link lsptMethod        @function.method.call
highlight default link lsptFunctionCall  @function.call

let b:current_syntax = "lspt"

let &cpo = s:keepcpo
unlet s:keepcpo
