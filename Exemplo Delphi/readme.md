
# Exemplo de integração em Delphi com a biblioteca PTI_DLL da plataforma de transações com cartão PayGo Web

### Funcionalidades implementadas neste exemplo:
 
  - Inicialização - Configura Biblioteca de Integração.
  - Conexão com POS.
  - Identificação do terminal conectado.
  - Menu
  - Captura de Dados com e sem mascara
  - Emissão de QR Code e Codigo Barras
  - Fluxo de Venda Completo
  
### Pré-requisitos
  - Delphi 
  - Windows
  - Cadastro no ambiente de testes/sandbox do PayGo Web
    - código do Ponto de Captura (PdC)
    - POS

### Configurando no Windows

### Como executar
Windows


#### Observações

1 O certificado "certificado.crt" na raiz do projeto é utilizado apenas no ambiente de testes, para ambiente produtivo utiliza-se outro arquivo.

2 PTI_DLL.DLL e certificado.crt devem ser colocada na pasta de criação do Projeto \Win32\Debug para compilação do mesmo. (Estas pastas são criadas na primeira compilação, copiar os arquivos e compilar novamente)
