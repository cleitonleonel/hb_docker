# Diretório de Trabalho (`workspace/`)

Este diretório serve como o ambiente de compilação e execução compartilhado entre o seu sistema host e os containers Docker do Harbour SDK.

## Como funciona

Quando você executa o script principal de compilação (como `../make.sh` ou atalhos como `../pdv_build.sh`), o seguinte processo ocorre em relação a esta pasta:

1. O container Docker correspondente à versão do sistema operacional escolhida é iniciado.
2. Todo este diretório `workspace/` (onde este arquivo se encontra) é mapeado (montado como um volume) diretamente para dentro do container no caminho `/workspace`.
3. O script de build acessa esta pasta e executa o compilador `hbmk2` a partir daqui.

## Vantagens dessa abordagem

- **Sincronização instantânea e bidirecional:** Qualquer código-fonte (arquivos `.prg`, projetos `.hbp`, includes `.ch`) ou recurso que você copiar para cá estará imediatamente disponível para o compilador dentro do container.
- **Acesso direto aos binários:** Os arquivos executáveis finais e bibliotecas gerados pelo Harbour de dentro do container serão salvos diretamente neste diretório. Você não precisa rodar comandos de cópia (`docker cp`) para recuperar o resultado da sua compilação.
- **Isolamento do projeto:** Mantém os arquivos gerados na compilação (como `.o`, `.c` intermediários e o binário final) separados dos scripts estruturais de infraestrutura do SDK.

## Uso comum

Você deve utilizar o `workspace/` como sua área principal para realizar os testes de compilação. Coloque seus arquivos fontes aqui ou configure os caminhos no seu arquivo `.hbp` para que os artefatos de saída sejam direcionados para esta pasta.

## Limpeza

Como este diretório geralmente contém os arquivos intermediários e finais da compilação, é seguro apagar os arquivos com extensão `.o`, `.c` (gerados pelo Harbour) ou o próprio binário caso você queira forçar uma recompilação totalmente limpa do zero.
