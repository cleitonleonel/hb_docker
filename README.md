# Harbour SDK — Guia de Execução

![harbour_container.png](harbour_container.png)

## Descrição

Este repositório contém utilitários para compilar aplicações Harbour dentro de ambientes containerizados usando Docker Compose. O script principal de build é o `make.sh`, que inicia os containers necessários (com opções para diferentes versões do Ubuntu), prepara o ambiente, instala automaticamente wrappers de linha de comando (se necessário) e chama o compilador `hbmk2` de forma transparente.

## Pré-requisitos

- Docker instalado (recomenda-se a versão mais recente estável).
- Docker Compose (embutido no Docker Desktop ou `docker-compose` compatível).
- Permissões de superusuário (`sudo`) localmente: O script pode solicitar sua senha para instalar os wrappers (`hbmk2`, `harbour`, etc.) em `/usr/local/bin`, permitindo que você use os comandos do Harbour no terminal como se estivessem instalados nativamente no seu sistema.
- Permissão para executar scripts (shell) no sistema.

## Estrutura do projeto (resumo)

- `make.sh` — Script principal que gerencia a subida dos containers e a execução da compilação.
- `docker-compose.yml` — Configuração dos serviços/containers usados durante a compilação (oferece ambientes baseados em Ubuntu 18.04 e 22.04).
- `Dockerfile.18` / `Dockerfile.22` — Receitas para construção das imagens com as dependências do Harbour e extensões de banco de dados (PostgreSQL, MariaDB, SQLite, etc.) para cada versão do sistema.
- `install-harbour-wrappers.sh` — Instala atalhos globais no host para os executáveis do Harbour, repassando os comandos para o container via `docker exec`.
- `workspace/` — Diretório onde a compilação é executada e os binários são gerados (criado automaticamente e mapeado para dentro do container).
- `*_build.sh` ou `*_compile.sh` — Exemplos de scripts (como `pdv_build.sh` e `consulta_build.sh`) que automatizam chamadas para o `make.sh`.

## Como usar

1) Torne o `make.sh` executável (apenas uma vez):

```bash
chmod +x make.sh
```

2) Execute o script para compilar um projeto (ex: `.hbp`) ou arquivo `.prg`. O comando repassa os argumentos para o `hbmk2` dentro do container.

```bash
./make.sh [opcoes_do_hbmk2] <arquivo_fonte.prg ou projeto.hbp> [--distro-version <18|22>]
```

Exemplo simples (usará a versão padrão baseada em Ubuntu 22.04):

```bash
./make.sh meu_projeto.hbp
```

### Escolhendo a versão do Sistema Operacional

Você pode escolher compilar em um ambiente baseado no Ubuntu 18.04 passando o parâmetro `--distro-version 18`. Se o parâmetro não for especificado, a compilação ocorrerá no ambiente baseado no Ubuntu 22.04 (padrão).

```bash
./make.sh meu_projeto.hbp --distro-version 18
```

### O que o script faz (resumo):

- Avalia o parâmetro `--distro-version` para decidir qual container (`harbour_sdk-18` ou `harbour_sdk-22`) iniciar.
- Executa `docker compose up -d` para subir o container correspondente em background.
- Verifica se os utilitários (`hbmk2`, `hbrun`, etc.) estão no `PATH` do seu host. Caso não estejam, ele invoca o `install-harbour-wrappers.sh` (o que pode pedir sua senha `sudo` para criar os links em `/usr/local/bin/`).
- Cria e acessa o diretório `workspace/`.
- Executa o comando de compilação dentro do ambiente: `hbmk2 -static <argumentos_fornecidos>`.

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

- **Wrappers (`hbmk2` e outros):** Os atalhos instalados em `/usr/local/bin` enviam o comando para o container em execução. A variável de ambiente `HARBOUR_CONTAINER` dita o container de destino (o `make.sh` exporta ela temporariamente). Se rodar `hbmk2` manualmente no terminal após instalar os wrappers, certifique-se de que o container esteja rodando.
- **Erro de permissão ao executar `make.sh`:** Rode `chmod +x make.sh`.
- **Erro "Nenhum arquivo para compilar":** O `make.sh` requer que você passe ao menos o arquivo principal (`.prg` ou `.hbp`).
- **Verifique os logs dos containers** para diagnosticar problemas no serviço Docker:

```bash
docker compose logs --follow
```

- **Bibliotecas C e Includes:** As imagens Docker (`Dockerfile.18` e `Dockerfile.22`) já vêm pré-configuradas com inúmeras bibliotecas C (Curl, OpenSSL, PostgreSQL, MariaDB, SQLite, GTK, X11, etc.). Se alguma biblioteca de sistema necessária faltar na sua build estática, você pode incluí-la no Dockerfile correspondente e rodar `docker compose build` para atualizar a sua imagem local.

## Recomendações adicionais

- O diretório `workspace/` do seu projeto local é mapeado via `docker-compose.yml` para a pasta `/workspace` do container. Assim, todos os códigos, arquivos copiados e artefatos de build gerados no processo de compilação vão aparecer diretamente no seu host (e vice-versa).

## Licença

Este README e os scripts são fornecidos sem garantia; adapte-os conforme suas necessidades.
