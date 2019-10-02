//************************************************************************************
  {
     unit:   POSPGWLib
     Classe: TPOSPGWLib

     Data de criação  :  02/07/2019
     Autor            :
     Descrição        :  Metodos de Interoperabilidade com DLL
   }
//************************************************************************************
unit uPOSPGWLib;

interface


uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils, system.AnsiStrings,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types, System.TypInfo, uPOSEnums, uLib;



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


       CPT_GetpszValue = record
            pszValue: Array[0..2048] of AnsiChar;
       end;
       PSZ_GetpszValue = Array[0..0] of CPT_GetpszValue;




  TPOSPGWLib = class
  private
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
    appCapabilities:string;
    appuiAutoDiscSec:UInt16;

    WszTerminalId :AnsiString;
    WszModel : AnsiString;
    WszMAC: AnsiString;
    WszSerNum: AnsiString;
    WszStatus: SHORT;


    constructor Create;
    Destructor  Destroy; Override; // declaração do metodo destrutor

    function Init:Integer;
    function Conexao:Integer;
    function NovaConexao:Integer;
    function menuoperacoes(WTerminal:AnsiString):Integer;
    function menuprincipal(WTerminal:AnsiString):Integer;
    function menuimpressao(WTerminal:AnsiString):Integer;
    function menucaptura(WTerminal:AnsiString):Integer;
    function menucodigos(WTerminal:AnsiString):Integer;
    function operacaovenda(WTerminal:AnsiString):Integer;
    function operacaocancela(WTerminal:AnsiString):Integer;
    function operacaoadmin(WTerminal:AnsiString):Integer;
    function confirmacao(Wterminal:AnsiString):Integer;
   // function ConexaoCancela:Integer;
   // function NovaConexaoCancela:Integer;
    function PrintResultParams(WterminalID:AnsiString):Integer;
    function pszGetInfoDescription(wIdentificador:Integer):string;
    function PrintReturnDescription(iReturnCode:Integer; pszDspMsg:string):Integer;
    function Finalizar:Integer;
    //
    //function ConexaoExemplo:Integer;
    //function Cancelamento:Integer;
    function MandaMemo(Descr:string):integer;
    function Desconectar:Integer;

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
                                           1:  funcionalidade de troco/saque;
                                           2:  funcionalidade de desconto;
                                           4:  valor fixo, sempre incluir;
                                           8:  impressão das vias diferenciadas do comprovante para Cliente/Estabelecimento;
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
                      PWOPER_SALE            33       Pagamento de mercadorias ou serviços.
                      PWOPER_ADMIN           32       Qualquer transação que não seja um pagamento (estorno,
                                                      pré-autorização, consulta, relatório, reimpressão de recibo,etc).
                      PWOPER_SALEVOID        34       Estorna uma transação de venda que foi previamente
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
  function PTI_EFT_GetInfo (pszTerminalId:AnsiString; iInfo:Int16;  uiBufLen:UInt16; var szValue:PSZ_GetpszValue;
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

uses  uLib02, Principal;


var

   sziRet : PSZ_GetiRet;

   szTerminalId:  PSZ_GetpszTerminalId;
   szModel: PSZ_GetpszModel;
   szMAC: PSZ_GetpszMAC;
   szSerNum: PSZ_GetpszSerNum;

   szValue: PSZ_GetpszValue;




//====================================
// Aguarda Conexão de POS
//====================================
function TPOSPGWLib.Conexao: Integer;
var
 iRet:Int16;
 IRetorno:Integer;
 ret : SHORT;
 I:Integer;

 caminho:string;

begin


     isRunning := True;


     I := 0;


     while I < 10000 do
     begin

         // Indica Finalizar Thread
         if (FPrincipal.Wfinalizar = 1) then
             begin
                Exit;
             end;

         ret := 99;

         // Executa metodo de espera por Nova Conexão
         PTI_ConnectionLoop(szTerminalId, szModel, szMAC, szSerNum, Ret);

         // Nova Conexão encontrada
         if(Ret = eCclasse.PTIRET_NEWCONN) then
            begin

               WszTerminalId := szTerminalId[0].pszTerminalId;
               WszModel      := szModel[0].pszModel;
               WszMAC        := szMAC[0].pszMAC;
               WszSerNum     := szSerNum[0].pszSerNum;


               result := Ret;

               Break;

               Exit;

            end;



        Sleep(300);

     end;




end;



//=======================================================================
// Confirmação de Transação, usado para Transações pendentes ou com erro
//=======================================================================
function TPOSPGWLib.confirmacao(Wterminal: AnsiString): Integer;
var
 ret : SHORT;
 tret: SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 retorno:AnsiString;
begin

        // Limpa buffer de teclas pressionadas
        PTI_ClearKey(WTerminal, ret);


        //Exemplo de menu:
        PTI_StartMenu(WTerminal, ret);
        PTI_AddMenuOption(WTerminal, 'SIM', ret);
        PTI_AddMenuOption(WTerminal, 'NAO', ret);
        PTI_ExecMenu(WTerminal, 'CONFIRMA TRANSACAO?', 30, puiSelection, ret);

        // Qual foi selecionado
        if (puiSelection = 0)then
           begin
            PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_SUCCESS, ret);
            MandaMemo('Transação Confirmada: PTICNF_SUCCESS ');
           end
        else
           begin
            PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_OTHERERR, ret);
            MandaMemo('Transação Confirmada: PTICNF_OTHERERR ');
           end;



end;










constructor TPOSPGWLib.Create;
begin

  // POSenums   := TCPOSEnums.Create;

end;



//=============================================
//  Desconectar Terminal, apenas de exemplo.
//=============================================
function TPOSPGWLib.Desconectar: Integer;
var
 ret : SHORT;
 key : SHORT;
begin

    // Mostra ao usuário que o Terminal será desconectado
    PTI_Display(WszTerminalId, 'Desconectar ', ret);

    // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
    PTI_WaitKey(WszTerminalId, 5, key, ret);

    MandaMemo('');
    MandaMemo('Terminal Desconectado - PTI_Disconnect');
    MandaMemo('');

    PTI_Disconnect(WszTerminalId, 0);



end;


destructor TPOSPGWLib.Destroy;
begin
  inherited;
end;


//==============================================
  {
      Finaliza uso da Biblioteca
  }
//==============================================
function TPOSPGWLib.Finalizar: Integer;
begin

    MandaMemo('');
    MandaMemo('Uso da biblioteca de integração foi Encerrado');
    FPrincipal.Wfinalizar := 1;
    Application.ProcessMessages;

    PTI_End();

end;

//==============================================
  {
      Inicializa Biblioteca
  }
//==============================================
function TPOSPGWLib.Init: Integer;
var
 ret : SHORT;
 caminho:string;
 retorno:string;
begin

    currentNumberOfTerminals := 0;
    Caminho := ExtractFilePath(ParamStr(0)) + pasta;
    appWorkingPath := caminho;
    appListeningPort := 10000;
    maxNumberOfTerminals := 50;
    msgIdle := 'APLICACAO TESTE';
    appCompany := 'NTK Solutions';
    appVersion := 'Aplicacao exemplo ' + POSenums.PGWEBLIBTEST_VERSION;
    appCapabilities := '63';
    appuiAutoDiscSec := 0;


    PTI_Init(appCompany, appVersion, appCapabilities, appWorkingPath, appListeningPort, maxNumberOfTerminals,msgIdle, appuiAutoDiscSec, ret);

    if (ret  <>  POSenums.PTIRET_OK) then
        begin
            // ShowMessage('ERRO AO INICIAR DLL: ' + IntToStr(ret));
        end;


    MandaMemo('PTI_Init ');

    MandaMemo('');

    MandaMemo('pszPOS_Company......: ' + appCompany);
    MandaMemo('pszPOS_Version......: ' + appVersion);
    MandaMemo('pszPOS_Capabilities.: ' + appCapabilities);
    MandaMemo('pszDataFolder.......: ' + appWorkingPath);
    MandaMemo('uiTCP_Port..........: ' + IntToStr(appListeningPort));
    MandaMemo('uiMaxTerminals......: ' + IntToStr(maxNumberOfTerminals));
    MandaMemo('pszWaitMsg..........: ' + msgIdle);
    MandaMemo('uiAutoDiscSec.......: ' + IntToStr(appuiAutoDiscSec));

    MandaMemo('');

    PrintReturnDescription(ret, '');




    Result := ret;


end;


//==============================================
  {
      Atualiza Log da Aplicação
  }
//==============================================
function TPOSPGWLib.MandaMemo(Descr:string): integer;
begin

    if (FPrincipal.Memo1.Visible = False) then
       begin
         FPrincipal.Memo1.Visible := True;
       end;
         FPrincipal.Memo1.Lines.Add(Descr);

    Result := 0;

end;


//=================================================
//  Menu de Captura de dados digitados no terminal
//=================================================
function TPOSPGWLib.menucaptura(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;

     while I < 10 do
     begin

         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;

         PTI_ClearKey(WTerminal, ret);

         // Inicia função de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona opção 1 do menu:
         PTI_AddMenuOption(WTerminal, 'CPF Mascarado', ret);
         // Adiciona opção 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'CPF Nao Mascarado', ret);
         // Adiciona opção 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conexão(TIMEOUT),
         // ao esgotar este tempo, a conexão é finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;


         // Verifica opção escolhida
         if(puiSelection = 0) then
            begin
               iRet :=  PTI_GetData(WTerminal, 'CPF C/Mascara'+chr(13), '@@@.@@@.@@@-@@', 11, 11, false, false, true, 30, pszData, 2, ret);
               WpszData := pszData[0].pszData;
               MandaMemo('');
               MandaMemo('CPF Com Mascara Capturado: ' + WpszData + ' - Terminal: ' + WTerminal);
               MandaMemo('');
               //Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                PTI_WaitKey(WszTerminalId, 5, key, ret);
               // Limpa Captura de Dados;
               pszData := wLimpapszdata;
            end
         else if (puiSelection = 1) then
            begin
               iRet :=  PTI_GetData(WTerminal, 'CPF S/Mascara'+chr(13), '@@@.@@@.@@@-@@', 11, 11, true, false, false, 30, pszData, 2, ret);
               WpszData := pszData[0].pszData;
               MandaMemo('');
               MandaMemo('CPF S/Mascara Capturado: ' + WpszData + ' - Terminal: ' + WTerminal);
               MandaMemo('');
               //Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                PTI_WaitKey(WTerminal, 5, key, ret);
               // Limpa Captura de Dados;
               pszData := wLimpapszdata;
            end
         else if (puiSelection = 2) then
            begin
               Break;
            end;


     end;


     Result := retorno;

end;

//==================================================
//  Menu de Impressão de Codigo de Barras ou QRCode
//==================================================
function TPOSPGWLib.menucodigos(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;

     while I < 10 do
     begin

         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;

         PTI_ClearKey(WTerminal, ret);

         // Inicia função de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona opção 1 do menu:
         PTI_AddMenuOption(WTerminal, 'Imprimir QR Code', ret);
         // Adiciona opção 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Imprimir C.Barras', ret);
         // Adiciona opção 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conexão(TIMEOUT),
         // ao esgotar este tempo, a conexão é finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;


         // verifica opção escolhida
         if(puiSelection = 0) then
            begin
                //Impressão de QR Code
                  MandaMemo('');
                  MandaMemo('Escolheu QR Code');
                  PTI_PrnSymbolCode(WTerminal, 'http://www.ntk.com.br', 4, ret);

                  //Avança algumas linhas do papel da impressora:
                  PTI_PrnFeed(WTerminal, ret);

            end
         else if (puiSelection = 1) then
            begin
                //Impressão de código de barras:
                  MandaMemo('');
                  MandaMemo('Escolheu Codigo de Barras');
                  PTI_PrnSymbolCode(WTerminal, '0123456789', 2, ret);

                  //Avança algumas linhas do papel da impressora:
                  PTI_PrnFeed(WTerminal, ret);

            end
         else if (puiSelection = 2) then
            begin
               Break;
            end;



     end;


     Result := retorno;

end;

//=============================================
//  Menu de Opções de Impressão
//=============================================
function TPOSPGWLib.menuimpressao(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;


     while I < 10 do
     begin

         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;



         PTI_ClearKey(WTerminal, ret);

         // Inicia função de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona opção 1 do menu:
         PTI_AddMenuOption(WTerminal, 'PrintReceipt', ret);
         // Adiciona opção 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Display', ret);
         // Adiciona opção 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Print', ret);
         // Adiciona opção 4 ao menu:
         PTI_AddMenuOption(WTerminal, 'PrnSymbolcode', ret);
         // Adiciona opção 5 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);

         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conexão(TIMEOUT),
         // ao esgotar este tempo, a conexão é finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;


               // verifica opção escolhida
               if (puiSelection = 0)then
                   begin
                   // Imprimir recibo
                      PTI_EFT_PrintReceipt(WTerminal, 3, ret);
                      if (ret = eCclasse.PTIRET_NODATA) then
                         begin
                            MandaMemo('');
                            MandaMemo('Não Existe Recibo a ser Impresso');
                            PTI_Display(WTerminal, 'Nao Existe Recibo: ', ret);
                            // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                            PTI_WaitKey(WTerminal, 5, key, ret);
                         end;
                      if (ret = eCclasse.PTIRET_NOPAPER) then
                         begin
                            MandaMemo('');
                            MandaMemo('Impressora sem Papel');
                            PTI_Display(WTerminal, 'Impressora sem Papel: ', ret);
                            // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                            PTI_WaitKey(WTerminal, 5, key, ret);
                         end;

                   end

               else if (puiSelection = 1) then
                    begin
                   //Imprimir na Tela
                     PTI_Display(WTerminal, 'Exemplo PTI_Display', ret);
                   //Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                     PTI_WaitKey(WTerminal, 5, key, ret);
                    end
               else if (puiSelection = 2) then
                    begin
                       // imprime na Ipressora
                       // Limpa Captura de Dados;
                          pszData := wLimpapszdata;
                       // Captura um Numero
                          iRet :=  PTI_GetData(WTerminal, 'Numero Para Imprimir'+chr(13), '@@@@@@', 1, 6, false, false, true, 30, pszData, 2, ret);
                       // Numero Digitado:
                          WpszData :=  'PTI_Print Informado: ' + pszData[0].pszData;
                       // Impressão do Numero:
                          PTI_Print(WTerminal, WpszData, ret);

                          MandaMemo('');
                          MandaMemo(WpszData + ' - Terminal: ' + WTerminal);
                          MandaMemo('');

                       // Avança Papel na Impressora
                          PTI_PrnFeed (WTerminal, ret);

                    end
               else if (puiSelection = 3) then
                    begin
                        begin
                           //Imprimir codigo de barras ou QRCode
                            retorno := menucodigos(WTerminal);
                            if (retorno = 1) then
                                Break;
                        end;
                    end
               else if (puiSelection = 4) then
                   // Sair do Menu
                      Break;

     end;


          Result := retorno;

end;


//=============================================
//  Menu de Operações:
//  Venda, Cancelamento e Administrativo
//=============================================
function TPOSPGWLib.menuoperacoes(WTerminal:AnsiString):Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin
     I := 0;


     while I < 10 do
     begin


         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;

         PTI_ClearKey(WTerminal, ret);

         // Inicia função de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona opção 1 do menu:
         PTI_AddMenuOption(WTerminal, 'Venda', ret);
         // Adiciona opção 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Cancelamento', ret);
         // Adiciona opção 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Administrativo', ret);
         // Adiciona opção 4 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conexão(TIMEOUT),
         // ao esgotar este tempo, a conexão é finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;

         // verifica opção escolhida
         if (puiSelection = 0)then
             operacaovenda(WTerminal)
         else if (puiSelection = 1) then
             operacaocancela(WTerminal)
         else if (puiSelection = 2) then
             operacaoadmin(WTerminal)
         else if (puiSelection = 3) then
             Break;


     end;


     Result := retorno;

end;


//=============================================
//  Menu Principal da Aplicação
//=============================================
function TPOSPGWLib.menuprincipal(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;


     while I < 10 do
     begin


         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;


         PTI_ClearKey(WTerminal, ret);

         // Inicia função de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona opção 1 do menu:
         PTI_AddMenuOption(WTerminal, 'Operacoes', ret);
         // Adiciona opção 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Captura de Dados', ret);
         // Adiciona opção 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Impressao', ret);
         // Adiciona opção 4 ao menu:
         PTI_AddMenuOption(WTerminal, 'Desconectar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);


         //========================================================
         // Verifica tempo default de espera da conexão(TIMEOUT),
         // ao esgotar este tempo, a conexão é finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);
               Break;
             end;



         // verifica opção escolhida
         if (puiSelection = 0)then
             begin
               retorno := menuoperacoes(WTerminal);
               if (retorno = 1) then
                  Break;
             end
         else if (puiSelection = 1) then
             begin
               retorno := menucaptura(WTerminal);
               if (retorno = 1) then
                  Break;
             end
         else if (puiSelection = 2) then
             begin
              retorno := menuimpressao(WTerminal);
               if (retorno = 1) then
                  Break;
             end
         else if (puiSelection = 3) then
             begin
                Break;
             end;


     end;


    // mensagem de desocectado na aplicação
    MandaMemo('');
    MandaMemo('Terminal: ' + WTerminal + ' Desconectado.');
    MandaMemo('');

    // desconecta terminal POS
    PTI_Disconnect(WTerminal, 0);


    Exit;



end;

//========================================================
//  Executa Processo em uma nova Conexão
//========================================================
function TPOSPGWLib.NovaConexao: Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 retorno:AnsiString;
 I:Integer;

begin

     key := 99;
     ret := 99;
     status := 99;
     puiSelection := -1;
     I := 0;

     //Mostra ao usuário o identificador do terminal que conectou:
     PTI_Display(WszTerminalId, 'TERMINAL '  + WszTerminalId +   chr(13) +  ' CONECTADO', ret);

     MandaMemo('');
     MandaMemo('Terminal Conectado: ' + WszTerminalId );

     // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
     PTI_WaitKey(WszTerminalId, 5, key, ret);

     // Consulta informações do terminal através da função PTI_CheckStatus:
     PTI_CheckStatus(WszTerminalId, status, WszModel, WszMAC, WszSerNum, ret);

     // Mostra ao usuário os dados obtidos através da função PTI_CheckStatus:
     PTI_Display(WszTerminalId, 'SERIAL: ' + WszSerNum + chr(13) + 'MAC: ' + WszMAC + chr(13) + 'MODELO: ' + WszModel + chr(13) +'Status: ' + IntToStr(status), ret);

     MandaMemo('Serial: ' + WszSerNum);
     MandaMemo('MAC   : ' + WszMAC);
     MandaMemo('Modelo: ' + WszModel);


     // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
     PTI_WaitKey(WszTerminalId, 5, key, ret);


     // Menu Principal
     menuprincipal(WszTerminalId);


     Exit;




     //================================



end;



//===============================================================
{
     Operação Administrativa
}
//===============================================================
function TPOSPGWLib.operacaoadmin(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
begin

    //Limpa Captura de Dados;
      pszData := wLimpapszdata;

    //Inicia transação Admin:
      PTI_EFT_Start(WTerminal, eCclasse.PWOPER_ADMIN, ret);

    //Executa transação:
      MandaMemo('Executou Transação Administrativa: ');
      PTI_EFT_Exec(WTerminal, ret);

      if (ret = eCclasse.PTIRET_OK) then
         begin
             // OK
         end
      else
         begin
             // Não retornou OK, vai para confirmação, pode existir transação pendente ou com erro.
             confirmacao(WTerminal);
         end;


      Exit;



end;



//=========================================================================
  {
     Operação de Cancelamento
  }
//=========================================================================
function TPOSPGWLib.operacaocancela(WTerminal: AnsiString): Integer;
var
  iRet: Int16;
  WpszData: AnsiString;
  RET:SHORT;
  key : SHORT;
  I:Integer;
  puiSelection:ShortInt;
  WData:string;
  retorno:AnsiString;
begin



            //Inicia transação de Cancelamento:
             PTI_EFT_Start(WTerminal, eCclasse.PWOPER_SALEVOID, ret);

             if (ret = eCclasse.PTIRET_CANCEL) then
                 begin
                   MandaMemo('Cancelamento Cancelado pela aplicação: ');
                   PTI_Display(WTerminal, 'Cancelado pela aplicacao: ', ret);
                   // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                   PTI_WaitKey(WTerminal, 5, key, ret);
                   Exit;
                 end;


            //Executa transação:
              PTI_EFT_Exec(WTerminal, ret);



            if (ret = 0)then           // Transação autorizada OK
               begin


                    // Mostra valores armazenados em todos PWINFO_
                    PrintResultParams(WTerminal);

                    // Impressão do comprovante da transação:
                    PTI_EFT_PrintReceipt(WTerminal, 3, ret);

                    // sinal sonoro
                    PTI_Beep(WTerminal, 0, ret);

                    // Menu de Confirmação:
                    PTI_StartMenu(WTerminal, ret);
                    PTI_AddMenuOption(WTerminal, 'SIM', ret);
                    PTI_AddMenuOption(WTerminal, 'NAO', ret);
                    PTI_ExecMenu(WTerminal, 'CONFIRMAR TRANSACAO?', 30, puiSelection, ret);

                    if (puiSelection = 0)then
                       begin
                        PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_SUCCESS, ret);
                       end
                    else
                       begin
                        PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_OTHERERR, ret);
                       end;

               end
            else
               begin

                    // Transação Pendente ou Falhou

                    // Mostra valores armazenados em todos PWINFO_???
                    PrintResultParams(WTerminal);

                    // retorno de mensagem
                    PTI_EFT_GetInfo(WTerminal, eCclasse.PWINFO_RESULTMSG, SizeOf(szValue), szValue, ret);

                    retorno := szValue[0].pszValue;
                    MandaMemo('');
                    MandaMemo(retorno);

                    // metodo de confirmação para o caso de transação pendente ou ter falhado
                    confirmacao(WTerminal);

               end;





end;


//=========================================================================
  {
     Operação de Venda
  }
//=========================================================================
function TPOSPGWLib.operacaovenda(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 tret: SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 retorno:AnsiString;
begin


     // Limpa Captura de Dados;
       pszData := wLimpapszdata;

     //=================================================
     // Inicia Transação de Venda:

    //Obtém do usuário o valor da transação:
     MandaMemo('Digite O Valor do Pagamento:');
     iRet :=  PTI_GetData(WTerminal, 'DIGITE VALOR PAGAMENTO ' +chr(13), '@@@.@@@,@@', 3, 8, false, false, false, 30, pszData, 2, ret);

     if (ret = eCclasse.PTIRET_CANCEL) then
         begin
           MandaMemo('Venda Abortada pela aplicação: ');
           PTI_Display(WTerminal, 'Venda Abortada ' + chr(13) + 'pela Aplicacao', ret);
           // Usa função de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
           PTI_WaitKey(WTerminal, 5, key, ret);
           Exit;
         end;

    //Inicia transação de pagamento:
     PTI_EFT_Start(WTerminal, eCclasse.PWOPER_SALE, ret);

    //Insere parâmetro "moeda":   986 = Real
     PTI_EFT_AddParam(WTerminal, eCclasse.PWINFO_CURRENCY, '986', ret);

    //Recupera Valor Total Digitado;
     WpszData := pszData[0].pszData;
     MandaMemo('Valor Informado: '  + WpszData + ' - Terminal: ' + WTerminal);
     MandaMemo('');

     // Adiciona Parametro Valor Total
     PTI_EFT_AddParam(WTerminal, eCclasse.PWINFO_TOTAMNT, WpszData, ret);

    //Executa transação:
     MandaMemo('Executa Transação de Venda: ');
     PTI_EFT_Exec(WTerminal, ret);


    if (ret = 0)then           // Transação autorizada OK
       begin

              // Mostra valores armazenados em todos PWINFO_???
              PrintResultParams(WTerminal);


              //Impressão de código de barras:
              PTI_PrnSymbolCode(WTerminal, '0123456789', 2, ret);

              //Impressão de QR Code
              PTI_PrnSymbolCode(WTerminal, 'http://www.ntk.com.br', 4, ret);

              //Avança algumas linhas do papel da impressora:
              PTI_PrnFeed(WTerminal, ret);

              //Impressão do comprovante da transação:
              PTI_EFT_PrintReceipt(WTerminal, 3, ret);


              PTI_Beep(WTerminal, 0, ret);

              // Limpa buffer de teclas pressionadas
              PTI_ClearKey(WTerminal, ret);


              //Exemplo de menu:
              PTI_StartMenu(WTerminal, ret);
              PTI_AddMenuOption(WTerminal, 'SIM', ret);
              PTI_AddMenuOption(WTerminal, 'NAO', ret);
              PTI_ExecMenu(WTerminal, 'CONFIRMA TRANSACAO?', 30, puiSelection, ret);

              if (puiSelection = 0)then
                 begin
                  PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_SUCCESS, ret);
                 end
              else
                 begin
                  PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_OTHERERR, ret);
                 end;

       end
    else
       begin
            // Transação Pendente ou Falhou

            // Mostra valores armazenados em todos PWINFO_???
            PrintResultParams(WTerminal);

            // recupera retorno de mensagem
            PTI_EFT_GetInfo(WTerminal, eCclasse.PWINFO_RESULTMSG, SizeOf(szValue), szValue, ret);

            retorno := szValue[0].pszValue;
            MandaMemo('');
            MandaMemo(retorno);

            // metodo de confirmação para o caso de pendente ou falhou
            confirmacao(WTerminal);


       end;




    Exit;




end;

//=====================================================================================*\
  {
     Funcao     :  PrintResultParams

     Descricao  :  Esta função exibe na tela todas as informações de resultado disponíveis
                   no momento em que foi chamada.

     Entradas   :  nao ha.

     Saidas     :  nao ha.

     Retorno    :  nao ha.
  }
//=====================================================================================*/
function TPOSPGWLib.PrintResultParams(WterminalID: AnsiString): Integer;
var
  I:Integer;
  Ir:Integer;
  volta:string;

  iRet:Integer;
  ret:SHORT;
  retorno:AnsiString;
  retornoMemo:AnsiString;
  WTexto:string;
  WTextoMemo:string;
  Wmax:Integer;

begin

   I := 0;
   WTexto := '';
   Wmax := 32000;

   while I < Wmax  do
   begin

       volta :=  pszGetInfoDescription(I);
       if (volta = 'PWINFO_XXX') then
          begin
            I := I+1;
            Continue;
          end;


       PTI_EFT_GetInfo(WterminalID, I, SizeOf(szValue), szValue, ret);

       if (ret = eCclasse.PTIRET_OK) then
           begin
             retorno := szValue[0].pszValue;
             WTexto := WTexto + volta + ' = ' + retorno + chr(13);
             WTextoMemo := WTextoMemo + volta + ' = ' + retorno + chr(13)+chr(10);
           end;

       I := I+1;

   end;


   //Impressão de texto:
   PTI_Print(WterminalID, WTexto, ret);

   MandaMemo('');
   MandaMemo(WTextoMemo);


end;


//=====================================================================================*\
  {
   Funcao     :  PrintReturnDescription

   Descricao  :  Esta função recebe um código PTIRET_XXX e imprime na tela a sua descrição.

   Entradas   :  iResult :   Código de resultado da transação (PTIRET_XXX).

   Saidas     :  nao ha.

   Retorno    :  nao ha.
  }
//=====================================================================================*/
function TPOSPGWLib.PrintReturnDescription(iReturnCode:Integer;
  pszDspMsg:string):Integer;
  var
    I : integer;
  begin

       case iReturnCode of


         POSenums.PTIRET_OK:
           begin
            MandaMemo('PTIRET_OK');
           end;

         POSenums.PTIRET_INVPARAM:
           begin
            MandaMemo('PTIRET_INVPARAM');
           end;

         POSenums.PTIRET_NOCONN:
           begin
            MandaMemo('PTIRET_NOCONN');
           end;

         POSenums.PTIRET_BUSY:
           begin
            MandaMemo('PTIRET_BUSY');
           end;

         POSenums.PTIRET_TIMEOUT:
           begin
            MandaMemo('PTIRET_TIMEOUT');
           end;

         POSenums.PTIRET_CANCEL:
           begin
            MandaMemo('PTIRET_CANCEL');
           end;

         POSenums.PTIRET_NODATA:
           begin
            MandaMemo('PTIRET_NODATA');
           end;

         POSenums.PTIRET_BUFOVRFLW:
           begin
            MandaMemo('PTIRET_BUFOVRFLW');
           end;

         POSenums.PTIRET_SOCKETERR:
           begin
            MandaMemo('PTIRET_SOCKETERR');
           end;

         POSenums.PTIRET_WRITEERR:
           begin
            MandaMemo('PTIRET_WRITEERR');
           end;

         POSenums.PTIRET_EFTERR:
           begin
            MandaMemo('PTIRET_EFTERR');
           end;

         POSenums.PTIRET_INTERNALERR:
           begin
            MandaMemo('PTIRET_INTERNALERR');
           end;

         POSenums.PTIRET_PROTOCOLERR:
           begin
            MandaMemo('PTIRET_PROTOCOLERR');
           end;

         POSenums.PTIRET_SECURITYERR:
           begin
            MandaMemo('PTIRET_SECURITYERR');
           end;

         POSenums.PTIRET_PRINTERR:
           begin
            MandaMemo('PTIRET_PRINTERR');
           end;

         POSenums.PTIRET_NOPAPER:
           begin
            MandaMemo('PTIRET_NOPAPER');
           end;

         POSenums.PTIRET_NEWCONN:
           begin
            MandaMemo('PTIRET_NEWCONN');
           end;

         POSenums.PTIRET_NONEWCONN:
           begin
            MandaMemo('PTIRET_NONEWCONN');
           end;

         POSenums.PTIRET_NOTSUPPORTED:
           begin
            MandaMemo('PTIRET_NOTSUPPORTED');
           end;

         POSenums.PTIRET_CRYPTERR:
           begin
            MandaMemo('PTIRET_CRYPTERR');
           end;

      else

         begin
           begin
            MandaMemo('OUTRO ERRO: ' + IntToStr(iReturnCode));
           end;

         end;






       end;



  end;




//=====================================================================================*\
  {
   Funcao     :  pszGetInfoDescription

   Descricao  :  Esta função recebe um código PWINFO_XXX e retorna uma string com a
                 descrição da informação representada por aquele código.

   Entradas   :  wIdentificador :  Código da informação (PWINFO_XXX).

   Saidas     :  nao ha.

   Retorno    :  String representando o código recebido como parâmetro.
  }
//=====================================================================================*/
  function TPOSPGWLib.pszGetInfoDescription(wIdentificador:Integer):string;
  begin

       case wIdentificador of

        eCclasse.PWINFO_OPERATION           :  Result := 'PWINFO_OPERATION';
        eCclasse.PWINFO_MERCHANTCNPJCPF     :  Result := 'PWINFO_MERCHANTCNPJCPF';
        eCclasse.PWINFO_TOTAMNT             :  Result := 'PWINFO_TOTAMNT';
        eCclasse.PWINFO_CURRENCY            :  Result := 'PWINFO_CURRENCY';
        eCclasse.PWINFO_FISCALREF           :  Result := 'PWINFO_FISCALREF';
        eCclasse.PWINFO_CARDTYPE            :  Result := 'PWINFO_CARDTYPE';
        eCclasse.PWINFO_PRODUCTNAME         :  Result := 'PWINFO_PRODUCTNAME';
        eCclasse.PWINFO_DATETIME            :  Result := 'PWINFO_DATETIME';
        eCclasse.PWINFO_REQNUM              :  Result := 'PWINFO_REQNUM';
        eCclasse.PWINFO_AUTHSYST            :  Result := 'PWINFO_AUTHSYST';
        eCclasse.PWINFO_VIRTMERCH           :  Result := 'PWINFO_VIRTMERCH';
        eCclasse.PWINFO_AUTMERCHID          :  Result := 'PWINFO_AUTMERCHID';
        eCclasse.PWINFO_FINTYPE             :  Result := 'PWINFO_FINTYPE';
        eCclasse.PWINFO_INSTALLMENTS        :  Result := 'PWINFO_INSTALLMENTS';
        eCclasse.PWINFO_INSTALLMDATE        :  Result := 'PWINFO_INSTALLMDATE';
        eCclasse.PWINFO_RESULTMSG           :  Result := 'PWINFO_RESULTMSG';
        eCclasse.PWINFO_AUTLOCREF           :  Result := 'PWINFO_AUTLOCREF';
        eCclasse.PWINFO_AUTEXTREF           :  Result := 'PWINFO_AUTEXTREF';
        eCclasse.PWINFO_AUTHCODE            :  Result := 'PWINFO_AUTHCODE';
        eCclasse.PWINFO_AUTRESPCODE         :  Result := 'PWINFO_AUTRESPCODE';
        eCclasse.PWINFO_DISCOUNTAMT         :  Result := 'PWINFO_DISCOUNTAMT';
        eCclasse.PWINFO_CASHBACKAMT         :  Result := 'PWINFO_CASHBACKAMT';
        eCclasse.PWINFO_CARDNAME            :  Result := 'PWINFO_CARDNAME';
        eCclasse.PWINFO_BOARDINGTAX         :  Result := 'PWINFO_BOARDINGTAX';
        eCclasse.PWINFO_TIPAMOUNT           :  Result := 'PWINFO_TIPAMOUNT';
        eCclasse.PWINFO_TRNORIGDATE         :  Result := 'PWINFO_TRNORIGDATE';
        eCclasse.PWINFO_TRNORIGNSU          :  Result := 'PWINFO_TRNORIGNSU';
        eCclasse.PWINFO_TRNORIGAUTH         :  Result := 'PWINFO_TRNORIGAUTH';
        eCclasse.PWINFO_LANGUAGE            :  Result := 'PWINFO_LANGUAGE';
        eCclasse.PWINFO_TRNORIGTIME         :  Result := 'PWINFO_TRNORIGTIME';
        eCclasse.PWPTI_RESULT               :  Result := 'PWPTI_RESULT';
        eCclasse.PWINFO_CARDENTMODE         :  Result := 'PWINFO_CARDENTMODE';
        eCclasse.PWINFO_CARDPARCPAN         :  Result := 'PWINFO_CARDPARCPAN';
        eCclasse.PWINFO_CHOLDVERIF          :  Result := 'PWINFO_CHOLDVERIF';
        eCclasse.PWINFO_MERCHADDDATA1       :  Result := 'PWINFO_MERCHADDDATA1';
        eCclasse.PWINFO_MERCHADDDATA2       :  Result := 'PWINFO_MERCHADDDATA2';
        eCclasse.PWINFO_MERCHADDDATA3       :  Result := 'PWINFO_MERCHADDDATA3';
        eCclasse.PWINFO_MERCHADDDATA4       :  Result := 'PWINFO_MERCHADDDATA4';
        eCclasse.PWINFO_PNDAUTHSYST         :  Result := 'PWINFO_PNDAUTHSYST';
        eCclasse.PWINFO_PNDVIRTMERCH        :  Result := 'PWINFO_PNDVIRTMERCH';
        eCclasse.PWINFO_PNDAUTLOCREF        :  Result := 'PWINFO_PNDAUTLOCREF';
        eCclasse.PWINFO_PNDAUTEXTREF        :  Result := 'PWINFO_PNDAUTEXTREF';
        eCclasse.PWINFO_DUEAMNT             :  Result := 'PWINFO_DUEAMNT';
        eCclasse.PWINFO_READJUSTEDAMNT      :  Result := 'PWINFO_READJUSTEDAMNT';
        else
        begin
          Result := 'PWINFO_XXX';
        end;

      end;


      end;



end.
