# lspt.nvim

Suporte completo à **Linguagem Senior de Programação** (LSP) no Neovim/NvChad.

Porte do excelente plugin VSCode [`llutti/vscode-language-lsp`](https://github.com/llutti/vscode-language-lsp) e do [`gtopanotti/lsp-formatter`](https://github.com/gtopanotti/lsp-formatter). Reaproveita **o mesmo language server** (Node.js) do projeto original — você ganha autocomplete, hover, signature help, go-to-definition, diagnósticos, quick fixes, refactors, formatter e SQL embutido, sem reimplementar nada.

## O que está incluído

- **Filetype**: detecção automática de `.lspt`
- **Syntax highlight** (Vim regex, portado do TextMate do plugin original)
- **Indentação** (Inicio/Fim, `{}`, `()`, `[]`, Senao)
- **Folding** por marcadores `@-- Bloco 'nome' --@` / `@-- FimBloco 'nome' --@`
- **Snippets** (32 snippets do plugin original, integrados ao LuaSnip)
- **LSP completo** via o servidor do projeto `llutti/vscode-language-lsp`
  - Autocomplete (funções, variáveis, métodos de Cursor/Lista)
  - Hover + signature help
  - Go-to-definition, references, rename
  - Diagnósticos sintáticos e semânticos
  - Code actions (quick fixes + refactors)
  - Formatter (`Format Document` equivalente: `vim.lsp.buf.format()`)
  - SQL embutido (formatação e highlight semântico opcionais)
- **Auto-pair** opcional para `inicio`/`fim;` e `@-- --@`
- **Comandos** equivalentes aos do VSCode

## Pré-requisitos

- Neovim **≥ 0.10**
- `git`, `npm` e `node` no `PATH` (para o auto-install do server)
- LuaSnip (para snippets)
- `blink.cmp` **ou** `cmp-nvim-lsp` (opcional, detectados automaticamente)

## Instalação (Lazy.nvim / NvChad)

```lua
-- lua/plugins/lspt.lua
return {
  {
    "<seu-usuario>/lspt.nvim",   -- ou caminho local: dir = "~/dev/lspt.nvim"
    ft = "lspt",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-nvim-lsp",     -- opcional
    },
    opts = {
      -- ver "Configuração" abaixo
    },
    config = function(_, opts)
      require("lspt").setup(opts)
    end,
  },
}
```

Depois rode:

```vim
:LsptInstallServer
```

Isso clona o repo do server em `~/.local/share/nvim/lspt-server`, roda `npm install` e `npm run build`. Em alguns minutos o server está pronto. Abra um `.lspt` e tudo deve funcionar.

## Configuração

### Defaults

```lua
require("lspt").setup({
  server = {
    auto_install = true,
    command      = nil,   -- ex: { "node", "/caminho/dist/server.js", "--stdio" }
    install_dir  = vim.fn.stdpath("data") .. "/lspt-server",
    repo         = "https://github.com/llutti/vscode-language-lsp.git",
    branch       = nil,
    node         = "node",
  },

  -- Settings repassadas ao server (= chaves "lsp.*" do VSCode original)
  server_settings = {
    contexts = {},   -- ver seção "Contextos" abaixo
    fallback = { defaultSystem = vim.NIL }, -- "HCM" | "ACESSO" | "ERP"
    format = {
      enabled          = true,
      indentSize       = 2,
      useTabs          = false,
      maxParamsPerLine = 4,
      embeddedSql = {
        enabled = false,
        dialect = "sql",    -- "sql" | "oracle" | "sqlserver"
      },
    },
    semantic = {
      embeddedSqlHighlight = { enabled = false },
    },
    refactor = { defaultBlockStyle = "inicioFim" },  -- ou "braces"
    diagnostics = { ignoreIds = {} },
    debug = { enabled = false, path = "" },
  },

  pairs = { enabled = false },   -- inicio/fim auto-pair
  cmp = true,                    -- usa cmp_nvim_lsp.default_capabilities

  on_attach = nil,               -- function(client, bufnr)
  capabilities = nil,            -- override completo
})
```

### Override manual do server

Se você já tem o server buildado em outro lugar:

```lua
require("lspt").setup({
  server = {
    auto_install = false,
    command = { "node", "/home/ruan/projects/vscode-language-lsp/packages/extension/dist/server.js", "--stdio" },
  },
})
```

### Contextos (validação multiarquivo)

Equivalente ao `lsp.contexts` do VSCode:

```lua
require("lspt").setup({
  server_settings = {
    contexts = {
      {
        name = "HR",
        rootDir = "HR",
        filePattern = "HR*.lspt",
        includeSubdirectories = false,
        system = "HCM",
      },
      {
        name = "TR",
        rootDir = "TR",
        filePattern = "re:^\\d+.*\\.lspt$",
        includeSubdirectories = false,
        system = "HCM",
      },
    },
  },
})
```

> ⚠️ Após alterar contextos, rode `:LsptRestart`.

### Integração com nvim-cmp

Plug-and-play se o `cmp_nvim_lsp` estiver instalado — o plugin chama `default_capabilities()` automaticamente. Configure seu cmp normalmente com `sources = { { name = "nvim_lsp" } }`.

## Comandos

| Comando                  | Descrição                                       |
| ------------------------ | ----------------------------------------------- |
| `:LsptInstallServer`     | Clona e builda o language server                |
| `:LsptRestart`           | Reinicia o client LSP                           |
| `:LsptStop`              | Para todos os clients                           |
| `:LsptInfo`              | Status atual (paths, clients ativos)            |
| `:LsptHealth`            | `:checkhealth lspt`                             |
| `:LsptContextCreate`     | Cria novo contexto (server-side)                |
| `:LsptContextEdit`       | Edita contexto                                  |
| `:LsptContextDelete`     | Remove contexto                                 |
| `:LsptContextValidate`   | Valida todos os contextos                       |
| `:LsptContextSettings`   | Abre configurações de contextos (server-side)   |
| `:LsptQuickFixConfirmName` | Aplica Quick Fix: confirmar nome              |
| `:LsptQuickFixEditPlan`  | Aplica Quick Fix: plano de edição               |
| `:LsptIgnoreId {id}`     | Ignora um ID de diagnóstico                     |
| `:LsptUnignoreId {id}`   | Para de ignorar                                 |
| `:LsptListIgnoredIds`    | Lista IDs ignorados                             |
| `:LsptClearIgnoredIds`   | Limpa lista de ignorados (workspace)            |
| `:LsptClearIgnoredIdsUser` | Limpa IDs ignorados (usuário, server-side)    |
| `:LsptSelectSystem`      | Seleciona sistema fallback (HCM/ACESSO/ERP)     |
| `:LsptFormatToggle`      | Liga/desliga formatter                          |
| `:LsptSnippets`          | Lista snippets disponíveis                      |

## Keymaps default (no buffer LSPT)

Aplicados via `on_attach`:

| Tecla        | Ação                       |
| ------------ | -------------------------- |
| `gd`         | Ir para definição          |
| `gr`         | Referências                |
| `K`          | Hover                      |
| `<leader>rn` | Rename                     |
| `<leader>ca` | Code action                |
| `<leader>f`  | Format                     |
| `<C-s>` (i)  | Signature help             |

Sobrescreva passando seu próprio `on_attach`:

```lua
require("lspt").setup({
  on_attach = function(client, bufnr)
    -- seus keymaps customizados
  end,
})
```

## Snippets disponíveis

São 32 snippets do plugin original. Alguns destaques:

| Prefix              | Resultado                                          |
| ------------------- | -------------------------------------------------- |
| `Inicio`            | Bloco `Inicio ... Fim;`                            |
| `da` / `dn` / `dd`  | Definir Alfa/Numero/Data                           |
| `dc` / `dl` / `dt`  | Definir Cursor/Lista/Tabela                        |
| `el`                | Enquanto Lista                                     |
| `es` / `ss` / `ssa` | SQL Enquanto / SQL Se / SQL Se+Achou               |
| `ex`                | ExecSQLEx com tratamento de erro                   |
| `sdi`/`sda`/`sdd`/`sdf` | SQL_DefinirInteiro/Alfa/Data/Flutuante         |
| `sri`/`sra`/`srd`/`srf` | SQL_RetornarInteiro/Alfa/Data/Flutuante        |
| `cor`               | Lógica para alternar cor de Seção de Relatório     |
| `lsp-sql-consulta`  | Pragma de classificação SQL                        |

Rode `:LsptSnippets` para listar todos.

## Limitações conhecidas

- **Tree-sitter**: usei syntax tradicional do Vim (regex). Funciona muito bem, mas se você quiser tree-sitter "de verdade" precisa de uma grammar dedicada — projeto separado.
- **Comandos VSCode-específicos** que dependem de UI nativa do VSCode (criar/editar contexto via wizard) chamam `workspace/executeCommand` no server. Se o server original implementou esses comandos com `vscode.window.showInputBox`, eles vão falhar silenciosamente — para esses, edite `server_settings.contexts` diretamente no `setup()` e rode `:LsptRestart`.
- **Auto-update do server**: `:LsptInstallServer` faz `git pull --ff-only` se o repo já existir e re-builda.

## Atualizar o server

```bash
rm -rf ~/.local/share/nvim/lspt-server
nvim -c "LsptInstallServer"
```

## Solução de problemas

```vim
:LsptHealth          " checa dependências e instalação
:LsptInfo            " status dos clients
:checkhealth lspt
:LspLog              " logs do cliente LSP nativo
```

## Créditos

- [llutti/vscode-language-lsp](https://github.com/llutti/vscode-language-lsp) — language server, gramática e snippets originais
- [gtopanotti/lsp-formatter](https://github.com/gtopanotti/lsp-formatter) — primeira implementação de syntax/formatter pra Linguagem Senior

## Licença

MIT (compatível com os projetos originais).
