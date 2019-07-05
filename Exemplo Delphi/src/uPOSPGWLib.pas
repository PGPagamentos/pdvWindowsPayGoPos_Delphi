//************************************************************************************
  {
     unit:   POSPGWLib
     Classe: TPOSPGWLib

     Data de criação  :  02/07/2019
     Autor            :
     Descrição        :
   }
//************************************************************************************
unit uPOSPGWLib;

interface


uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils, system.AnsiStrings,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types, System.TypInfo, uPOSEnums;



Type

       CPT_GetpszData = record
            pszData: Array[0..21] of AnsiChar;
       end;
       PSZ_GetpszData = Array[0..0] of CPT_GetpszData;



       CPT_GetpszTerminalId = record
            pszTerminalId: Array[0..21] of AnsiChar;
       end;
       PSZ_GetpszTerminalId = Array[0..0] of CPT_GetpszTerminalId;


       CPT_GetpszModel = record
            pszModel: Array[0..21] of AnsiChar;
       end;
       PSZ_GetpszModel = Array[0..0] of CPT_GetpszModel;


       CPT_GetpszMAC = record
            pszMAC: Array[0..18] of AnsiChar;
       end;
       PSZ_GetpszMAC = Array[0..0] of CPT_GetpszMAC;


       CPT_GetpszSerNum = record
            pszSerNum: Array[0..26] of AnsiChar;
       end;
       PSZ_GetpszSerNum = Array[0..0] of CPT_GetpszSerNum;


       CPT_GetiStatus = record
            piStatus: Byte;
       end;
       PSZ_GetiStatus = Array[0..0] of CPT_GetiStatus;

       CPT_GetiRet = record
            piRet: Integer;
       end;
       PSZ_GetiRet = Array[0..0] of CPT_GetiRet;




  TPOSPGWLib = class
  private
  //private
    { private declarations }
  protected
    { protected declarations }
  public

    POSenums   : TCPOSEnums;


    isRunning: Boolean;

    appListeningPort: Integer;
    currentNumberOfTerminals: Integer;
    maxNumberOfTerminals: Integer;
    pasta:string;

    msgIdle:String;
    appCompany:string;
    appVersion:string;
    appWorkingPath:string;


    WszTerminalId :AnsiString;
    WszModel : AnsiString;
    WszMAC: AnsiString;
    WszSerNum: AnsiString;



    constructor Create;
    Destructor  Destroy; Override; // declaração do metodo destrutor



end;




//===============================================================================================*\
 {

 Function     :  TPOSPGWLib.PTI_Init

 Descricao    : Esta função configura a biblioteca de integração e deve ser a primeira a ser chamada
                pela Automação Comercial. A biblioteca de integração somente aceitará conexões do terminal
                de pagamento após sua chamada.


 Entrada:       pszPOS_Company  .........= Nome da empresa de Automação Comercial (final-nulo, até 40 caracteres e sem acentuação). Por exemplo, "KND SISTEMAS LTDA.".


                pszPOS_Version  .........= Nome e versão da aplicação de Automação Comercial (final-nulo, até 40 caracteres e sem acentuação).
                                           Por exemplo, “SUPERVENDAS v1.01”.


                pszPOS_Capabilities .....= Capacidades da Automação (soma dos valores abaixo):
                                           1: funcionalidade de troco/saque;
                                           2: funcionalidade de desconto;
                                           4: valor fixo, sempre incluir;
                                           8: impressão das vias diferenciadas do comprovante para Cliente/Estabelecimento;
                                           16: impressão do cupom reduzido.
                                           32: utilização de saldo total do voucher para abatimento do valor da compra.

                pszDataFolder ...........= Caminho completo do diretório para armazenar dados e logs da biblioteca de integração.
                                           Observação: O usuário do sistema operacional onde é executada a aplicação de Automação Comercial
                                           deve ter permissão de gravação nesse diretório

                uiTCP_Port  .............= Porta TCP à qual todos os terminais irão conectar.
                                           Observação: esta porta deve estar habilitada para o recebimento de conexões
                                           através de qualquer firewall que estiver no caminho entre a aplicação de Automação Comercial e o terminal de POS.

                uiMaxTerminals ......... = Número máximo de conexões simultâneas de terminais.

                pszWaitMsg ............. = Mensagem a ser apresentada na tela de qualquer terminal imediatamente após se conectar. Veja PTI_Display para informações de formatação.


               uiAutoDiscSec ........... = Tempo de ociosidade em segundos após o qual o terminal deve se desconectar da Automação Comercial
                                           quando opera sem alimentação externa, ou zero para nunca desconectar. Veja PTI_Disconnect para informações adicionais.



 Saidas        :  none.

 Retorno       :  PTIRET_OK          Operação bem-sucedida
                  PTIRET_INVPARAM    Parâmetro inválido informado à função
                  PTIRET_SOCKETERR   Erro ao iniciar a escuta da porta TCP informada
                  PTIRET_WRITEERR    Erro no uso do diretório informado
 }
//===============================================================================================*/
  function PTI_Init(pszPOS_Company:AnsiString; pszPOS_Version:AnsiString; pszPOS_Capabilities:AnsiString;
                        pszDataFolder:AnsiString; uiTCP_Port:UInt16; uiMaxTerminals:UInt16;
                        pszWaitMsg:AnsiString; uiAutoDiscSec:UInt16;  var iRet:SHORT):Int16;  stdCall; External 'PTI_DLL.dll';


 //===============================================================================================
   {
     Function      :  PTI_End

     Descricao     :  Esta função deve ser a última função chamada pela Automação Comercial, quando finalizada
                      ou antes de descarregar a biblioteca de integração.
                      Neste momento, a biblioteca de integração libera todos recursos alocados (portas TCP, processos, memória, etc.).

     Input         :  none.

     Output        :  none.

     Return        :  none.
  }
//===============================================================================================*/
  function PTI_End():Int16; stdCall; External 'PTI_DLL.dll';




//===============================================================================================
  {
     Function      :  PTI_CheckStatus

     Descricao     :  Esta função permite que a Automação Comercial verifique o status (on-line ou offline)
                      de determinado terminal de pagamento e recupere informações adicionais do equipamento.

                      Cada terminal de pagamento recebe um único identificador lógico, que é configurado quando o
                      terminal é instalado. Se a Automação Comercial controla mais de um terminal, ela deve ter registro
                      de todos os identificadores e suas localizações, com a finalidade de poder enviar comandos para o terminal desejado.


     Entrada       :  pszTerminalId  Identificador único do terminal (final nulo). Pode ser vazio se o número máximo de terminais
                      suportado (informado em PTI_Init) for 1.


     Saida         :  pszTerminalId  Identificador único do terminal (final nulo, até 20 caracteres).

                      piStatus       Status do terminal (PTISTAT_xxx).

                      pszModel       Modelo do terminal (final nulo até 20 caracteres).

                      pszMAC         Endereço MAC do terminal (final nulo, formato “XX:XX:XX:XX:XX:XX”)

                      pszSerNo       Número de série do terminal (final nulo, até 25 caracteres).

     Retorno      :  PTIRET_OK      Operação bem sucedida.


     Lista de Possiveis Status(piStatus):
     ==================================
     Nome              Valor     Descrição
     PTISTAT_IDLE        0       Terminal está on-line
     PTISTAT_BUSY        1       Terminal está on-line, porém ocupado processando um comando.
     PTISTAT_NOCONN      2       Terminal está offline.
     PTISTAT_WAITRECON   3       Terminal está off-line. A transação continua sendo executada e
                                 após sua finalização, o terminal tentará efetuar a reconexão
                                 automaticamente.
  }
//===============================================================================================
  function PTI_CheckStatus(pszTerminalId:  AnsiString; var piStatus:SHORT; pszModel:AnsiString;
                           pszMAC:AnsiString; pszSerNo:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//==============================================================================================
  {
     Function      :  PTI_Disconnect

     Descricao     :  Esta função permite que a Automação Comercial desconecte um terminal de pagamento e o coloque
                      em modo offline, seja imediatamente ou após algum tempo funcionando sem alimentação externa.

                      Para terminais móveis, permanecer on-line aumenta consideravelmente o consumo da bateria. Por
                      este motivo é recomendado que a Automação Comercial defina um valor diferente de zero para o
                      parâmetro uiAutoDiscSec de PTI_Init, ou chame essa função assim que o terminal conectar.

                      Após o terminal ficar offline, tão logo uma tecla é pressionada, este se conecta automaticamente
                      novamente à Automação Comercial.


     Entrada       :  pszTerminalId  Identificador único do terminal (final nulo).

                      uiPwrDelay     Se igual a zero, desconecta imediatamente o terminal, independentemente
                                     de sua fonte de energia.
                                     Se diferente de zero, representa o número máximo de segundos durante os
                                     quais o terminal permanecerá on-line enquanto estiver operando sem
                                     alimentação externa. O terminal não ficará offline enquanto estiver
                                     conectado a uma fonte de alimentação externa. Este valor sobrescreve o
                                     parâmetro uiAutoDiscSec de PTI_Init para este terminal específico.

     Saida         :  none.

     Retorno       :  PTIRET_OK      Operação bem-sucedida.
                      PTIRET_NOCONN  O terminal está offline.
                      PTIRET_BUSY     O terminal está ocupado processando outro comando
   }
//===============================================================================================
  function PTI_Disconnect(pszTerminalId:AnsiString; uiPwrDelay:UInt16):Int16; stdCall; External 'PTI_DLL.dll';




//===============================================================================================
  {
    Function       :  PTI_Display

    Descricao      :  Esta função apresenta uma mensagem na tela do terminal e retorna imediatamente.
                      A mensagem é apresentada a partir do canto superior esquerdo da tela, sendo 20 caracteres por
                      linha, com quebra de linha identificada pelo caractere ‘\r’ (retorno ao início da linha, código
                      ASCII 13). Caracteres que ultrapassem as 20 colunas ou o número máximo de linhas são descartados.
                      O número máximo de linhas suportado pode variar dependendo do modelo do terminal, entretanto
                      o mínimo de quatro linhas é sempre suportado.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).
                      pszMsg         Mensagem a ser apresentada na tela do terminal (final nulo).

    Saida          :  none.

    Retorno        :  PTIRET_OK            Operação bem-sucedida.
                      PTIRET_INVPARAM      Parâmetro inválido passado à função. PTIRET
                      PTIRET_NOCONN        O terminal está offline
                      PTIRET_BUSY          O terminal está ocupado processando outro comando

   }
//===============================================================================================
  function PTI_Display(pszTerminalId:AnsiString; pszMsg:AnsiString; var iRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//============================================================================================================================================
  {
    Function       :  PTI_WaitKey

    Descricao      :  Esta função aguarda o pressionar de uma tecla no terminal e apenas retorna após uma tecla ser
                      pressionada ou quando o tempo de espera se esgotar
                      Importante: Esta função somente deve ser utilizada para captura isolada de teclas, não devendo ser
                      sucessivamente chamada para captura de dados de entrada. Para este propósito, PTI_GetData deve
                      ser utilizado.


    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).
                      uiTimeOutSec   Tempo de espera do usuário, em segundos. Se igual a zero, a função retorna
                                     imediatamente, somente informando que uma tecla foi pressiona caso tenha
                                     sido feito antes da chamada à função. (Captura de tecla buferizada.)

    Saida          :  piKey          Identificador da tecla que foi pressionada, de acordo com a tabela abaixo
                                     (somente se o retorno da função for PTIRET_OK).

    Retorno        :  PTIRET_OK            Operação bem-sucedida, uma tecla foi pressionada.
                      PTIRET_NOCONN        O terminal está offline
                      PTIRET_BUSY          O terminal está ocupado processando outro comando.
                      PTIRET_TIMEOUT       Nenhuma tecla foi pressionada durante o período de tempo
                                           especificado.

   }
//============================================================================================================================================
  function PTI_WaitKey(pszTerminalId:AnsiString; uiTimeOutSec:UInt16; var piKey:SHORT; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//===========================================================================
  {
    Funcao     :  PTI_ConnectionLoop

    Descricao  :  Esta função permite que a Automação Comercial verifique quando um novo
                  terminal se conectou e, se PTIRET_NEWCONN é retornado,
                  recupere informações adicionais do equipamento.

    Entradas   :  nenhuma.

    Saidas     :  pszTerminalId  : Identificador único do terminal (final nulo, até 20 caracteres).
                  pszModel       : Modelo do terminal (final nulo, até 20 caracteres).
                  pszMAC         : Endereço MAC do terminal (final nulo, formato “XX:XX:XX:XX:XX:XX”).
                  pszSerNo       : Número serial do terminal (final nulo, até 25 caracteres).


    Retorno    :  PTIRET_NEWCONN    :  Novo terminal conectado.
                  PTIRET_NONEWCONN  :  Sem novas conexões recebidas.
  }
//===========================================================================

  function PTI_ConnectionLoop(var pszTerminalId:PSZ_GetpszTerminalId; var pszModel:PSZ_GetpszModel; var pszMAC:PSZ_GetpszMAC;
                              var pszSerNo:PSZ_GetpszSerNum; var piRet:Int16):Int16; stdCall; External 'PTI_DLL.dll';




//========================================================================================================
  {
    Function       :  PTI_ClearKey

    Descrição      :  Esta função limpa o buffer de teclas pressionadas,
                      para que a próxima chamada da função não considere qualquer tecla previamente pressionada.
                      Esta função retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK             Operação bem-sucedida
                      PTIRET_NOCONN         O terminal está offline
                      PTIRET_BUSY           O terminal está ocupado processando outro comando.
   }
//========================================================================================================
  function PTI_ClearKey (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//===============================================================================================
  {
  Function       :  PTI_GetData

  Descrição      :  Esta função realiza a captura de um único dado em um terminal previamente conectado.
                    Esta função é blocante e somente retorna após a captura de dado ser bem-sucedida ou falhar.

  Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).
                    pszPrompt      Mensagem de texto com final nulo a ser apresentada ao usuário,
                                   descrevendo a informação a ser solicitada.
                                   Utilize ‘\r’ (código ASCII 13) para quebra de linha. Por exemplo: “VALOR DO SERVICO:”.
                    pszFormat      Máscara de formatação com final nulo. Utilize ‘@’ (arroba) para as posições de caracteres editáveis.
                                   Por exemplo: “@@.@@@.@@@,@@” para um valor em centavos.
                                   Deve ser nulo (NULL) ou vazio para captura direta sem formatação
                    uiLenMin       Número mínimo de caracteres
                    uiLenMax       Número máximo de caracteres
                    fFromLeft      TRUE (1) para iniciar a digitação da esquerda;
                                   FALSE (0) para iniciar a digitação da direita.
                    fAlpha         TRUE (1) para habilitar a entrada de caracteres não numéricos;
                                   FALSE (0) para permitir apenas caracteres numéricos.
                                   Nota: como a digitação de caracteres não numéricos em muitos terminais não é amigável,
                                   recomenda-se evitar o uso desse recurso sempre que possível
                    fMask          TRUE (1) para mascarar os caracteres digitados com asterisco
                                   (tipicamente, para digitação de senha);  FALSE (0) para mostrar os caracteres digitados
                    uiTimeOutSec   Tempo máximo entre cada tecla pressionada, em segundos.
                    pszData        Valor inicial para um dado a ser editado com final nulo.
                    uiCaptureLine  Índice da linha da tela (iniciando em 1) onde a informação digitada deve ser apresentada.
                                   Caso a legenda da mensagem também for apresentada nessa linha,
                                   a informação digitada será exibida logo após a legenda;
                                   senão, será exibida iniciando na primeira coluna.

  Saida          :  pszData  Informação digitada com final nulo (somente caso a função retorne PTIRET_OK)

  Retorno        :  PTIRET_OK            Captura de dado bem-sucedida
                    PTIRET_INVPARAM      Parâmetro inválido passado à função
                    PTIRET_NOCONN        O terminal está offline.
                    PTIRET_BUSY          O terminal está ocupado processando outro comando
                    PTIRET_TIMEOUT       Nenhuma tecla foi pressionada no tempo especificado.
                    PTIRET_CANCEL        Usuário pressionou a tecla [CANCELA].
                    PTIRET_SECURITYERR   A função foi rejeitada por questões de segurança.
   }
//===============================================================================================
  function PTI_GetData (pszTerminalId:AnsiString; pszPrompt:AnsiString; pszFormat:AnsiString; uiLenMin:UInt16;
                        uiLenMax:UInt16; fFromLef:BOOL; fAlpha:BOOL; fMask:BOOL;
                        uiTimeOutSec:UInt16; var pszData:PSZ_GetpszData; uiCaptureLine:UInt16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//=========================================================================================================
  {
    Function       :  PTI_StartMenu

    Descrição      :  Esta função inicia a construção de um menu de opção para seleção pelo usuário.
                      Esta função retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

    Saida          :  Nenhum.

    Retorno        :  PTIRET_OK       Criação do menu iniciada
                      PTIRET_NOCONN   O terminal está offline
                      PTIRET_BUSY     O terminal está ocupado processando outro comando.
   }
//=========================================================================================================
  function PTI_StartMenu (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//===================================================================================================================================
  {
    Function       :  PTI_AddMenuOption

    Descrição      :  Esta função adiciona uma opção ao menu que foi criado através de PTI_StartMenu.
                      Esta função retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).
                      pszOption      Mensagem de texto com final nulo que descreve a opção a ser exibida no
                                     terminal (máximo: 18 caracteres).

    Saida          :  none.

    Retorno        :  PTIRET_OK        A opção foi adicionada ao menu
                      PTIRET_INVPARAM  Parâmetro inválido passado à função
                      PTIRET_NOCONN    O terminal está offline.
                      PTIRET_BUSY      O terminal está ocupado processando outro comando
   }
//===================================================================================================================================
  function PTI_AddMenuOption (pszTerminalId:AnsiString; pszOption:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//=============================================================================================================================
  {
      Function       :  PTI_ExecMenu

      Descrição      :  Esta função exibe o menu de opções que foi criado através de PTI_StartMenu
                        e PTI_AddMenuOption e identifica a seleção feita pelo usuário.
                        Esta função é blocante e somente retorna após a seleção de uma opção ou a ocorrência de um erro.

      Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).
                        pszPrompt      Mensagem de texto com final nulo a ser apresentada ao usuário
                                       no topo do menu (máximo: 20 caracteres).
                                       Por exemplo: “SELECIONE UMA OPCAO:”.
                                       Caso NULL ou vazio, o menu é exibido a partir da primeira linha da tela.
                        uiTimeOutSec   Tempo máximo entre duas teclas pressionadas, em segundos.
                        puiSelection   Índice (iniciado em zero) da opção que deve estar pré-selecionada quando o
                                       menu for inicialmente exibido, fazendo com que esta opção seja selecionada
                                       se o usuário simplesmente pressionar [OK]. Caso puiSelection não seja uma
                                       opção válida, nenhuma é pré-selecionada.


      Saida         :  puiSelection   Índice (iniciado em zero) da opção que foi selecionada pelo usuário (somente
                                      se a função retornar PGWRET_OK)

      Retorno       :  PTIRET_OK          Seleção do menu bem-sucedida.
                       PTIRET_INVPARAM    Parâmetro inválido passado à função
                       PTIRET_NOCONN      O terminal está offline.
                       PTIRET_BUSY        O terminal está ocupado processando outro comando
                       PTIRET_TIMEOUT     Nenhuma tecla foi pressionada durante o tempo especificado
                       PTIRET_CANCEL      Usuário pressionou a tecla [CANCELA].
   }
//=============================================================================================================================
  function PTI_ExecMenu (pszTerminalId:AnsiString; pszPrompt:AnsiString; uiTimeOutSec:UInt16;
                         var puiSelection:ShortInt; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';


//==================================================================================================================
  {
    Function       :  PTI_Beep

    Descrição      :  Esta função emite um aviso sonoro no terminal. Esta função retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).
                      iType          Tipo de aviso sonoro, de acordo com a tabela abaixo

    Saida          :  Nenhuma.

    Retorno        :  PTIRET_OK          Operação bem-sucedida
                      PTIRET_INVPARAM    Parâmetro inválido passado à função
                      PTIRET_NOCONN      O terminal está offline
                      PTIRET_BUSY        O terminal está ocupado processando outro comando
  }
//==================================================================================================================
  function PTI_Beep (pszTerminalId:AnsiString; iType:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//==========================================================================================================================
  {
    Function       :  PTI_Print

    Descrição      :  Esta função imprime uma ou mais linhas de texto na impressora do terminal e
                      retorna imediatamente. Até 40 caracteres por linha podem ser impressos,
                      com quebras de linha identificadas pelo caractere ‘\r’ (código ASCII 13).
                      Caracteres além das 40 colunas serão descartados.
                      Um caractere de controle na primeira posição de uma linha indica a mudança
                      da fonte do caractere utilizada para o texto da linha inteira.
                      Caso o primeiro caractere de uma linha não é um caractere de controle,
                      a fonte padrão é utilizada. Os caracteres de controle suportados são:

                     Caractere de controle   Código ASCII do caractere         Efeito
                     =====================   =========================         ======
                          ‘\v’                          11                Dobra a largura da fonte, consequentemente
                                                                          o número de colunas suportado é dividido por dois.


                     "PTI_PrnFeed deve ser chamada após uma ou mais chamadas a PTI_Print."


    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

                      pszText        Texto a ser impresso (final nulo).

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK            Operação bem-sucedida
                      PTIRET_INVPARAM      Parâmetro inválido passado à função
                      PTIRET_NOCONN        O terminal está offline
                      PTIRET_BUSY          O terminal está ocupado processando outro comando
                      PTIRET_NOTSUPORTED   Função não suportada pelo terminal
  }
//==========================================================================================================================
  function PTI_Print (pszTerminalId:AnsiString; pszText:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//========================================================================================================
  {
      Function       :  PTI_PrnFeed

      Descrição      :  Esta função avança algumas linhas do papel da impressora,
                        para permitir que o usuário destaque o recibo

      Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

      Saida          :  Nenhuma.

      Retorno(piRet) :  PTIRET_OK            Operação bem-sucedida
                        PTIRET_INVPARAM      Parâmetro inválido passado à função
                        PTIRET_NOCONN        O terminal está offline
                        PTIRET_BUSY          O terminal está ocupado processando outro comando
                        PTIRET_PRINTERR      Erro na impressora
                        PTIRET_NOPAPER       Impressora sem papel
                        PTIRET_NOTSUPORTED   Função não suportada pelo terminal
   }
//========================================================================================================
  function PTI_PrnFeed (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//=======================================================================================================================
  {
    Function       :  PTI_EFT_Start

    Descrição      :  A Automação Comercial deve chamar esta função para iniciar qualquer nova transação.
                      Esta função retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

                      iOper          Tipo de transação, de acordo a tabela abaixo

    Saida          :  Nenhuma.

    Retorno        :  PTIRET_OK         Operação bem-sucedida
                      PTIRET_INVPARAM   Parâmetro inválido passado à função.
                      PTIRET_NOCONN     O terminal está offline
                      PTIRET_BUSY       O terminal está ocupado processando outro comando

                      Lista dos tipos de transações:
                      ==============================
                      Nome                  Valor     Descrição
                      ====================  =====     ====================================
                      PWOPER_SALE            21h      Pagamento de mercadorias ou serviços.
                      PWOPER_ADMIN           20h      Qualquer transação que não seja um pagamento (estorno,
                                                      pré-autorização, consulta, relatório, reimpressão de recibo,etc).
                      PWOPER_SALEVOID        22h      Estorna uma transação de venda que foi previamente
                                                      realizada e confirmada.
  }
//=======================================================================================================================
  function PTI_EFT_Start (pszTerminalId:AnsiString; iOper:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//===============================================================================================================================================
  {
    Function       :  PTI_EFT_AddParam

    Descrição      :  A Automação Comercial deve chamar esta função iterativamente após PTI_EFT_Start para definir
                      todos os parâmetros disponíveis para a transação. Esta função retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

                      iParam         Identificador do parâmetro, de acordo com o capítulo “TAG’s de entrada e saída”.

                      pszValue       Valor do parâmetro (final nulo).

    Saida         :  none.

    Retorno       :  PTIRET_OK         Successful operation.
                     PTIRET_INVPARAM   Invalid parameter passed to the function.
                     PTIRET_NOCONN     The terminal is offline.
                     PTIRET_BUSY       The terminal is busy processing another command.
   }
//===============================================================================================================================================
  function PTI_EFT_AddParam (pszTerminalId:AnsiString; iParam:Int16; pszValue:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//=========================================================================================================
  {
    Function       :  PTI_EFT_Exec

    Descrição      :  Esta função efetua de fato a transação, utilizando os parâmetros que foram previamente
                      definidos através de PTI_EFT_AddParam.
                      Esta função é blocante, e somente retorna após a conclusão (ou falha) da transação.

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK          Operação bem-sucedida (para venda, significa transação aprovada).
                      PTIRET_INVPARAM    Parâmetro inválido passado à função
                      PTIRET_NOCONN      O terminal está offline.
                      PTIRET_BUSY        O terminal está ocupado processando outro comando
                      PTIRET_EFTERR      A transação foi realizada, entretanto falhou
   }
//=========================================================================================================
  function PTI_EFT_Exec (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//===========================================================================================================
  {
    Function       :  PTI_EFT_GetInfo

    Descrição      :  A Automação Comercial deve chamar esta função iterativamente para recuperar
                      os dados relativos à transação que foi realizada (com ou sem sucesso) pelo terminal.
                      Esta função retorna imediatamente

    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

                      iInfo          Identificador da informação a ser obtida,
                                     conforme o capítulo “TAG’s de entrada e saída”.

                      uiBufLen       Tamanho (em bytes) do buffer referenciado pelo ponteiro pszValue

    Saida          :  pszValue       Informação recuperada (final nulo).

    Retorno(piRet) :  PTIRET_OK          Operação bem-sucedida, informação retornada
                      PTIRET_INVPARAM    Parâmetro inválido passado à função.
                      PTIRET_BUFOVRFLW   O tamanho do dado é maior que uiBufLen.
                      PTIRET_NOCONN      O terminal está offline
                      PTIRET_BUSY        O terminal está ocupado processando outro comando
                      PTIRET_NODATA      Informação não disponível.
   }
//===========================================================================================================
  function PTI_EFT_GetInfo (pszTerminalId:AnsiString; iInfo:Int16;  uiBufLen:UInt16; var pszValue:AnsiString;
                            var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//==============================================================================================================================
  {
    Function       :  PTI_EFT_PrintReceipt

    Descrição      : Esta função faz com que o terminal imprima o comprovante da última transação realizada.
                     A Automação Comercial pode optar por:
                    . Utilizar esta função para imprimir uma ou ambas as vias (estabelecimento e/ou portador do
                      cartão) do comprovante de pagamento;
                    . Recuperar o conteúdo do comprovante através de PTI_EFT_GetInfo e:
                      .Imprimir uma ou ambas as vias em uma impressora dedicada
                      .Enviar a cópia do portador do cartão por e-mail ou outro tipo de mensageria;
                    Nota: a via do estabelecimento deve sempre ser impressa quando PWINFO_CHOLDVERIF
                    (recuperado através de PTI_EFT_GetInfo) indicar que a assinatura do portador do cartão é requerida.

    Entrada         : pszTerminalId  Identificador único do terminal (final nulo).

                      iCopies        Soma dos valores da tabela abaixo.

    Saidas          : pszValue Informação recuperada (final nulo).

    Retorno         : PTIRET_OK         Bem-sucedida, impressão iniciada
                      PTIRET_INVPARAM   Parâmetro inválido passado à função.
                      PTIRET_NOCONN     O terminal está offline
                      PTIRET_BUSY       O terminal está ocupado processando outro comando
                      PTIRET_NODATA     Não há recibo a ser impresso
                      PTIRET_PRINTERR   Erro na impressora
                      PTIRET_NOPAPER    Impressora sem papel

                      Identificadores da cópia do recibo:
                      ===================================
                      Nome                  Valor     Descrição
                      ================      =====     ======================
                      PTIPRN_MERCHANT         1       Via do estabelecimento
                      PTIPRN_CHOLDER          2       Via do portador do cartão


   }
//==============================================================================================================================
  function PTI_EFT_PrintReceipt (pszTerminalId:AnsiString; iCopies:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//============================================================================================================================
  {
    Function       :  PTI_EFT_Confirm

    Descrição      :  Qualquer transação financeira bem-sucedida (PTI_EFT_Exec retorna PTIRET_OK) deve ser
                      confirmada pela Automação Comercial através desta função para assegurar a integridade da
                      transação entre todas as partes (Automação Comercial e registro fiscais, terminal, adquirente,
                      emissor e portador do cartão).
                      Múltiplas transações podem ser realizadas simultaneamente por diversos terminais, entretanto, para
                      cada terminal, a transação deve ser confirmada antes de outra ser iniciada. Em cada momento,
                      somente pode haver no máximo uma única transação pendente para cada terminal.
                      Para minimizar cenários de desfazimento, é recomendável que a Automação Comercial confirme a
                      transação tão logo seja possível. Caso PTI_EFT_Exec retorne PTIRET_OK e a Automação Comercial
                      não confirmar a transação imediatamente, esta deve ser armazenada em memória não volátil
                      (arquivo) com todas as informações necessárias para confirmar ou desfazer a transação em caso de
                      queda de energia que ocorra após esse momento.
                      Eventos que podem levar a um desfazimento da transação são:
                      . Falha na impressora (quando a assinatura do portador do cartão for requerida);
                      . Mercadoria não pode ser entregue (mecanismo do dispensador falha ou equivalente);
                      . Falta de energia (portador do cartão utilizou um método de pagamento alternativo antes da volta
                        da energia).


    Entrada        :  pszTerminalId  Identificador único do terminal (final nulo).

                      iStatus        Status final da transação, conforme detalhado abaixo.

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK         Confirmação realizada.
                      PTIRET_INVPARAM   Parâmetro inválido passado à função.

                      Lista de possíveis status final para a transação:
                      =================================================
                      Nome             Valor      Descrição
                      =============    =====      =====================
                      PTICNF_SUCCESS     1        Transação confirmada
                      PTICNF_PRINTERR    2        Erro na impressora, desfazer a transação.
                      PTICNF_DISPFAIL    3        Erro com o mecanismo dispensador, desfazer a transação.
                      PTICNF_OTHERERR    4        Outro erro, desfazer a transação.
   }
//============================================================================================================================
  function  PTI_EFT_Confirm (pszTerminalId:AnsiString; iStatus:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//====================================================================================================
  {
    Funcao     :   PTI_PrnSymbolCode

    Descricao  :   Esta função imprime um código de barras ou QR code na impressora do terminal.

    Entradas   :   pszTerminalId  :  Identificador único do terminal (final nulo).
                   pszMsg         :  Código a ser impresso.
                   iSymbology     :  Tipo de código, conforme tabela abaixo.

    Saidas     :   Nenhuma.

    Retorno    :   PTIRET_OK          : Operação bem sucedida.
                   PTIRET_INVPARAM    : Parâmetro inválido passado à função.
                   PTIRET_INTERNALERR : Erro interno da biblioteca de integração.
                   PTIRET_NOCONN      : O terminal está offline.
                   PTIRET_BUSY        : O terminal está ocupado processando outro comando.

                   Tabela de tipos de código:
                   ==========================
                   Nome            Valor   Descrição
                   ============    =====   ===============
                                           Código de barras padrão 128.
                   CODESYMB_128      2     Código de barras padrão 128. Pode-se utilizar aproximadamente
                                           31 caracteres alfanuméricos.

                                           Código de barras padrão ITF
                   CODESYMB_ITF      3     Pode-se utilizar aproximadamente
                                           30 caracteres alfanuméricos.

                                           QR Code. Com aceitação de
                   CODESYMB_QRCODE   4     aproximadamente 600 caracteres
                                           alfanuméricos.
   }
//====================================================================================================
  function  PTI_PrnSymbolCode (pszTerminalId:AnsiString; pszMsg:AnsiString; iSymbology:Int16;
                               var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';







implementation

var


   sziRet : PSZ_GetiRet;

   szTerminalId:  PSZ_GetpszTerminalId;
   szModel: PSZ_GetpszModel;
   szMAC: PSZ_GetpszMAC;
   szSerNum: PSZ_GetpszSerNum;
   pszData: PSZ_GetpszData;





constructor TPOSPGWLib.Create;
begin


end;

destructor TPOSPGWLib.Destroy;
begin

  inherited;
end;






end.
