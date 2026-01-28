# Harbour SDK — Guia de Execução

![harbour_container.png](harbour_container.png)

## Descrição

Este repositório contém utilitários e exemplos para compilar aplicações Harbour dentro de um ambiente containerizado usando Docker Compose. O script principal de build é o `make.sh`, que inicia os containers necessários, prepara o diretório de trabalho `workspace` e chama o compilador `hbmk2`.

## Pré-requisitos

- Docker instalado (recomenda-se a versão mais recente estável).
- Docker Compose (embutido no Docker Desktop ou `docker-compose` compatível).
- Permissão para executar scripts (shell) no sistema.
- Se desejar compilar localmente sem containers: ter o `hbmk2` instalado no sistema.

Observação: O `hbmk2` normalmente é provido pelo ambiente Harbour dentro dos containers fornecidos neste projeto; o `make.sh` assume que os containers configurados no `docker-compose.yml` fornecem as ferramentas necessárias.

## Estrutura do projeto (resumo)

- `make.sh` — Script principal que sobe os containers e chama `hbmk2`.
- `docker-compose.yml` — Configuração dos serviços/containers usados durante a compilação.
- `workspace/` — Diretório onde a compilação é executada e os binários são gerados (criado automaticamente pelo `make.sh`).
- Outros diretórios de exemplos (ex.: `hello`, `hbcrud`, `dbmanager`).

## Como usar

1) Torne o `make.sh` executável (apenas uma vez):

```bash
chmod +x make.sh
```

2) Executar o script para compilar um arquivo `.prg` que esteja no diretório do projeto (ou informe caminho relativo/absoluto). O primeiro parâmetro é o arquivo fonte; o segundo é opcional e repassado ao `hbmk2`.

```bash
./make.sh <arquivo_fonte.prg> [opcoes_do_hbmk2]
```

Exemplo:

```bash
./make.sh ../hello/hello.prg
```

O que o script faz (resumo):

- Executa `docker compose up -d` para subir os containers em background.
- Cria `workspace/` caso não exista.
- Entra em `workspace/` e roda `hbmk2 -static <arquivo> <opcoes>` para gerar binário estático.
- Imprime mensagens simples de progresso.

Observações sobre parâmetros

- `$1` — arquivo fonte a ser compilado (obrigatório).
- `$2` — opções extras que serão repassadas ao `hbmk2` (opcional).

Exemplo com opções:

```bash
./make.sh ../hello/hello.prg "-D MY_DEFINE"
```

## Parar e limpar containers

Para parar os containers criados pelo `docker compose` e remover as redes associadas, rode:

```bash
docker compose down
```

Se quiser também remover volumes nomeados (cuidado com dados persistidos):

```bash
docker compose down -v
```

## Dicas e troubleshooting

- Erro: "command not found: hbmk2"
  - Significa que o compilador não está disponível no PATH dentro do ambiente atual. Garanta que os containers foram iniciados corretamente ou instale o `hbmk2` localmente.

- Erro: permissão negada ao executar `make.sh`
  - Rode `chmod +x make.sh` ou execute com `sh make.sh <arquivo>`.

- Verifique os logs dos containers para diagnosticar problemas com dependências:

```bash
docker compose logs --follow
```

- Se a compilação falhar com erros do `hbmk2`, verifique que o caminho passado (`$1`) aponta para um arquivo `.prg` válido e que os includes/bibliotecas referenciadas estão disponíveis no `workspace` ou no container.

## Recomendações adicionais

- Mantenha o Docker atualizado e com permissões corretas para o seu usuário (ou use `sudo` quando necessário).
- Se pretende compilar frequentemente, considere mapear um volume com o código fonte para dentro do container via `docker-compose.yml`.

## Exemplo rápido (fluxo completo)

```bash
# tornar o script executável
chmod +x make.sh

# compilar exemplo
./make.sh hello.prg

# conferir saída no workspace
ls -la workspace

# parar containers quando terminar
docker compose down
```

## Licença

Este README e os scripts são fornecidos sem garantia; adapte-os conforme suas necessidades.
