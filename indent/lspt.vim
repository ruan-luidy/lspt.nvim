" indent/lspt.vim
" Indentação para a Linguagem Senior de Programação.
" Regras (do lsp-configuration.json):
"   - Aumenta indent quando a linha termina com `{`, `(`, `[` ou palavra `inicio`
"   - Diminui indent quando a linha começa com `}`, `)`, `]` ou palavra `fim`

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=LsptIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,=fim,=Fim,=FIM,=senao,=Senao
setlocal autoindent

let b:undo_indent = "setlocal indentexpr< indentkeys< autoindent<"

if exists("*LsptIndent")
  finish
endif

function! s:strip_comments_strings(line) abort
  " Remove strings e comentários da linha para análise de indent.
  let l:s = a:line
  let l:s = substitute(l:s, '/\*.\{-}\*/', '', 'g')
  let l:s = substitute(l:s, '@--.\{-}--@', '', 'g')
  let l:s = substitute(l:s, '"\([^"\\]\|\\.\)*"', '""', 'g')
  let l:s = substitute(l:s, "'\\([^'\\\\]\\|\\\\.\\)*'", "''", 'g')
  return l:s
endfunction

function! s:prev_nonblank_codeline(lnum) abort
  let l:n = a:lnum - 1
  while l:n > 0
    let l:t = getline(l:n)
    " pula linhas vazias ou que são comentários puros
    if l:t !~ '^\s*$' && l:t !~ '^\s*@--.*--@\s*$'
      return l:n
    endif
    let l:n -= 1
  endwhile
  return 0
endfunction

function! LsptIndent(lnum) abort
  if a:lnum == 1
    return 0
  endif

  let l:prev = s:prev_nonblank_codeline(a:lnum)
  if l:prev == 0
    return 0
  endif

  let l:prev_text  = s:strip_comments_strings(getline(l:prev))
  let l:curr_text  = s:strip_comments_strings(getline(a:lnum))
  let l:ind        = indent(l:prev)
  let l:sw         = shiftwidth()

  " Aumenta se prev termina com inicio, {, (, [
  if l:prev_text =~? '\(^\|\s\)\<inicio\>\s*$'
        \ || l:prev_text =~ '[{([]\s*$'
    let l:ind += l:sw
  endif

  " 'Senao' isolado: alinha com Se (heurística simples - usa indent do anterior)
  if l:prev_text =~? '^\s*\<senao\>\s*$'
    let l:ind += l:sw
  endif

  " Diminui se a linha atual começa com fim, }, ), ]
  if l:curr_text =~? '^\s*\<fim\>'
        \ || l:curr_text =~ '^\s*[})\]]'
    let l:ind -= l:sw
  endif

  " 'Senao' deve alinhar com o Se anterior (volta um nível)
  if l:curr_text =~? '^\s*\<senao\>\s*;\?\s*$'
    let l:ind -= l:sw
  endif

  if l:ind < 0
    let l:ind = 0
  endif

  return l:ind
endfunction
