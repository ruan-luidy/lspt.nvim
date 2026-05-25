-- AUTO-GERADO a partir de packages/extension/snippets.json do plugin VSCode original.
-- 32 snippets convertidos. Editar à mão? Edite snippets.json e rode o conversor.
return {
  {
    name = "ComentarioLinha",
    prefix = "//",
    description = "Comentário de Linha",
    body = {
      "@-- $1 --@",
    },
  },
  {
    name = "InicioBlocoCodigo",
    prefix = "InicioBlocoCodigo",
    description = "Comentário de Linha, para iniciar um bloco de código",
    body = {
      "@-- Bloco '$1' --@",
    },
  },
  {
    name = "LSP SQL Consulta",
    prefix = "lsp-sql-consulta",
    description = "Pragma para classificar a variável seguinte como consulta SQL",
    body = {
      "@lsp-sql-consulta@",
      "Definir Alfa ${1:aSQL};",
    },
  },
  {
    name = "LSP SQL Fragmento",
    prefix = "lsp-sql-fragmento",
    description = "Pragma para classificar a variável seguinte como fragmento SQL estrutural",
    body = {
      "@lsp-sql-fragmento@",
      "Definir Alfa ${1:aFragmento};",
    },
  },
  {
    name = "FimBlocoCodigo",
    prefix = "FimBlocoCodigo",
    description = "Comentário de Linha, para encerrar um bloco de código",
    body = {
      "@-- FimBloco '$1' --@",
    },
  },
  {
    name = "Inicio Fim",
    prefix = "Inicio",
    description = "Inicio ... Fim",
    body = {
      "Inicio",
      "\t$1",
      "Fim;",
    },
  },
  {
    name = "Definir Alfa",
    prefix = "da",
    description = "Definir uma variável do tipo 'Alfa'",
    body = {
      "Definir Alfa a$1;",
    },
  },
  {
    name = "Definir Numero",
    prefix = "dn",
    description = "Definir uma variável do tipo 'Numero'",
    body = {
      "Definir Numero n$1;",
    },
  },
  {
    name = "Definir Data",
    prefix = "dd",
    description = "Definir uma variável do tipo 'Data'",
    body = {
      "Definir Data d$1;",
    },
  },
  {
    name = "Definir Cursor",
    prefix = "dc",
    description = "Definir uma variável do tipo 'Cursor'",
    body = {
      "Definir Cursor Cur_$1;",
    },
  },
  {
    name = "Definir Lista",
    prefix = "dl",
    description = "Definir uma variável do tipo 'Lista'",
    body = {
      "Definir Lista lst_$1;",
    },
  },
  {
    name = "Definir Tabela",
    prefix = "dt",
    description = "Definir uma variável do tipo 'Tabela' com schema inicial",
    body = {
      "Definir Tabela ${1:tb_Nome}[${2:10}] = {",
      "\tAlfa ${3:Campo}[${4:30}];",
      "};",
    },
  },
  {
    name = "Definir Funcao",
    prefix = "df",
    description = "Definir uma variável do tipo 'Funcao'",
    body = {
      "Definir Funcao f$1;",
    },
  },
  {
    name = "CR",
    prefix = "dcr",
    description = "Definir uma variável 'Alfa' e atribuir o valor #13",
    body = {
      "Definir Alfa CR; RetornaASCII(13, CR);",
      "$1",
    },
  },
  {
    name = "CRLF",
    prefix = "dcrlf",
    description = "Definir uma variável 'Alfa' e atribuir o valor #13#10",
    body = {
      "Definir Alfa CR; RetornaASCII(13, CR);",
      "Definir Alfa LF; RetornaASCII(10, LF);",
      "Definir Alfa CRLF; CRLF = CR + LF;",
      "$1",
    },
  },
  {
    name = "cor",
    prefix = "cor",
    description = "Regra para alternar a cor de uma Seção de Relatório",
    body = {
      "Definir alfa aCor;",
      "Definir alfa aSecao;",
      "",
      "aSecao = \"${1}\";",
      "",
      "ProximaPagina(aSecao, nProximaPagina);",
      "",
      "Se ((nCor = 0)",
      "ou  (nProximaPagina = 1))",
      "Inicio",
      "\tnCor = 1;",
      "\taCor = \"#F5F5F5\";",
      "Fim;",
      "Senao",
      "Inicio",
      "\tnCor = 0;",
      "\taCor = \"Branco\";",
      "Fim;",
      "AlteraControle(aSecao, \"Cor\", aCor);",
    },
  },
  {
    name = "Enquanto Lista",
    prefix = "el",
    description = "Criar um Enquanto para uma Lista",
    body = {
      "${1:lst_dados}.Primeiro();",
      "Enquanto (${1:lst_dados}.FDA = cFalso)",
      "Inicio",
      "\t$2",
      "\t${1:lst_dados}.Proximo();",
      "Fim;",
    },
  },
  {
    name = "ExecSQLEx",
    prefix = "ex",
    description = "Lógica para executar um 'ExexSQLEx'",
    body = {
      "ExecSQLEx(\"$1",
      "          \", nRetErro, aMsgErro);",
      "",
      "Se (nRetErro = 1) @-- Se Ocorreu algum erro --@",
      "Inicio",
      "\t",
      "Fim; ",
    },
  },
  {
    name = "Se SQL",
    prefix = "ss",
    description = "Lógica para executar um 'Se' para 'SQL_' e setar a variável 'nAchou'",
    body = {
      "SQL_Criar(${1:cPesquisa});",
      "SQL_UsarSQLSenior2(${1:cPesquisa}, 0);",
      "SQL_UsarAbrangencia(${1:cPesquisa}, 0);",
      "SQL_DefinirComando(${1:cPesquisa}, \"$2",
      "                              \");",
      "SQL_AbrirCursor(${1:cPesquisa});",
      "Se (SQL_EOF(${1:cPesquisa}) = cFalso)",
      "Inicio",
      "\t",
      "Fim;",
      "SQL_FecharCursor(${1:cPesquisa});",
      "SQL_Destruir(${1:cPesquisa});",
    },
  },
  {
    name = "SQL Achou",
    prefix = "ssa",
    description = "Lógica para executar um 'Se' para 'SQL_'",
    body = {
      "SQL_Criar(${1:cPesquisa});",
      "SQL_UsarSQLSenior2(${1:cPesquisa}, 0);",
      "SQL_UsarAbrangencia(${1:cPesquisa}, 0);",
      "SQL_DefinirComando(${1:cPesquisa}, \"$2",
      "                              \");",
      "SQL_AbrirCursor(${1:cPesquisa});",
      "nAchou = cFalso;",
      "Se (SQL_EOF(${1:cPesquisa}) = cFalso)",
      "Inicio",
      "  nAchou = cVerdadeiro;",
      "Fim;",
      "SQL_FecharCursor(${1:cPesquisa});",
      "SQL_Destruir(${1:cPesquisa});",
    },
  },
  {
    name = "SQL Enquanto",
    prefix = "es",
    description = "Lógica para executar um 'Enquanto' para 'SQL_'",
    body = {
      "SQL_Criar(${1:cPesquisa});",
      "SQL_UsarSQLSenior2(${1:cPesquisa}, 0);",
      "SQL_UsarAbrangencia(${1:cPesquisa}, 0);",
      "SQL_DefinirComando(${1:cPesquisa}, \"$2",
      "                              \");",
      "",
      "SQL_AbrirCursor(${1:cPesquisa});",
      "Enquanto (SQL_EOF(${1:cPesquisa}) = cFalso)",
      "Inicio",
      "\t",
      "\tSQL_Proximo(${1:cPesquisa});",
      "Fim;",
      "SQL_FecharCursor(${1:cPesquisa});",
      "SQL_Destruir(${1:cPesquisa});",
    },
  },
  {
    name = "SQL Definir Inteiro",
    prefix = "sdi",
    description = "Definir um parâmetro do tipo 'INTEIRO' para 'SQL_'",
    body = {
      "SQL_DefinirInteiro(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Definir Data",
    prefix = "sdd",
    description = "Definir um parâmetro do tipo 'DATA' para 'SQL_'",
    body = {
      "SQL_DefinirData(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Definir Alfa",
    prefix = "sda",
    description = "Definir um parâmetro do tipo 'ALFA' para 'SQL_'",
    body = {
      "SQL_DefinirAlfa(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Definir Flutuante",
    prefix = "sdf",
    description = "Definir um parâmetro do tipo 'DECIMAL' para 'SQL_'",
    body = {
      "SQL_DefinirFlutuante(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Retornar Inteiro",
    prefix = "sri",
    description = "Retornar um valor do tipo 'INTEIRO' de um 'SQL_'",
    body = {
      "SQL_RetornarInteiro(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Retornar Data",
    prefix = "srd",
    description = "Retornar um valor do tipo 'DATA' de um 'SQL_'",
    body = {
      "SQL_RetornarData(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Retornar Alfa",
    prefix = "sra",
    description = "Retornar um valor do tipo 'ALFA' de um 'SQL_'",
    body = {
      "SQL_RetornarAlfa(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "SQL Retornar Flutuante",
    prefix = "srf",
    description = "Retornar um valor do tipo 'DECIMAL' de um 'SQL_'",
    body = {
      "SQL_RetornarFlutuante(cPesquisa, \"$1\", $2);",
    },
  },
  {
    name = "ConverteParaMaiusculo",
    prefix = "cm",
    description = "Lógica para Converter o conteúdo de uma variável para Maiúsculo",
    body = {
      "ConverteParaMaiusculo(${1}, ${1});",
    },
  },
  {
    name = "TiraEspacos",
    prefix = "te",
    description = "Lógica para remover os espaços em branco do começo e do final",
    body = {
      "TiraEspacos(${1}, ${1});",
    },
  },
  {
    name = "AlteraControle",
    prefix = "ad",
    description = "Lógica para modificar a descrição de um 'label' no gerador de relatórios",
    body = {
      "AlteraControle(\"$1\", \"Descrição\", \"$2\");",
    },
  },
}
