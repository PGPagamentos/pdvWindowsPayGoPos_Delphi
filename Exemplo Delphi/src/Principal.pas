unit Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, uPOSPGWLib, uPOSEnums,
  Vcl.ExtCtrls;


Type
TNovaConexao = class(TThread)
  private
     FAux: String;
     FMemo: TMemo;
     wTipo: string;
     WszTerminalId :AnsiString;
     WszModel : AnsiString;
     WszMAC: AnsiString;
     WszSerNum: AnsiString;
  protected
    //procedure Execute; override;
  public
    constructor Create(NszTerminalId:AnsiString; NszModel:AnsiString; NszMAC: AnsiString; NszSerNum: AnsiString);
    procedure Execute; override;
    procedure Sincronizar;
  end;


Type
TAguardaConexao = class(TThread)
  private
     FAux: String;
     wTipo: string;

     terminalId: AnsiString;
     mac: AnsiString;
     model: AnsiString;
     serialNumber: AnsiString;

  protected
    //procedure Execute; override;
  public
    //constructor Create(AMemo: TMemo); reintroduce;
    constructor Create(); reintroduce;
    procedure Execute; override;
    procedure Sincronizar;
    procedure Terminate;
  end;



type
  TFPrincipal = class(TForm)
    Button2: TButton;
    Button1: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public

    POSPGWLib  : TPOSPGWLib;
    POSenums   : TCPOSEnums;

    currentNumberOfTerminals: Integer;
    maxNumberOfTerminals: Integer;
    appWorkingPath:string;


    WszTerminalId :AnsiString;
    WszModel : AnsiString;
    WszMAC: AnsiString;
    WszSerNum: AnsiString;

    Wfinalizar:Integer;

    Constructor Create;             // declaração do metodo construtor

    Destructor  Destroy; Override; // declaração do metodo destrutor

  end;

var
  FPrincipal: TFPrincipal;

  iRet:Integer;


implementation

{$R *.dfm}
//==============================================
// Método Construtor da Thread de Novas conexões
//==============================================
constructor TNovaConexao.Create(NszTerminalId:AnsiString; NszModel:AnsiString; NszMAC: AnsiString; NszSerNum: AnsiString);
begin

   inherited Create(True);

    WszTerminalId := NszTerminalId;
    WszModel      := NszModel;
    WszMAC        := NszMAC;
    WszSerNum     := NszSerNum;

   // Libera da memoria o objeto após terminar.
   Self.FreeOnTerminate := True;

   FAux := '';


end;
//==============================================
// Executa Thread de Novas conexões
//==============================================
procedure TNovaConexao.Execute;
var
  I: Integer;
  POSPGWLib  : TPOSPGWLib;

begin
  inherited;

  POSPGWLib  := TPOSPGWLib.Create;


  POSPGWLib.WszTerminalId := WszTerminalId;
  POSPGWLib.WszModel      := WszModel;
  POSPGWLib.WszMAC        := WszMAC;
  POSPGWLib.WszSerNum     := WszSerNum;


  POSPGWLib.NovaConexao();




end;

//==============================================
// Atualizar aqui o Form caso seja necessário
//==============================================
procedure TNovaConexao.Sincronizar;
begin
   // FMemo.Lines.Add(Self.FAux);
end;

//==================================================
// Método Construtor da Thread que Aguarda conexões
//==============================================
constructor TAguardaConexao.Create;
begin

   inherited Create(True);

   // Libera da memoria o objeto após terminar.
   Self.FreeOnTerminate := True;

   FAux := '';

end;


//=======================================
{
     Thread que Aguarda Novas Conexões
}
//=======================================
procedure TAguardaConexao.Execute;
var
  I: Integer;
  T:Integer;
  vThreadNovaConexao : TNovaConexao;
  POSPGWLib  : TPOSPGWLib;
  Retorno:Integer;
  Wthr:Integer;

begin
  inherited;


      I := 0;

      while I < 10 do
      begin


         POSPGWLib  := TPOSPGWLib.Create;

         Retorno := POSPGWLib.Conexao();

         // Finalizar Thread
         if (FPrincipal.Wfinalizar = 1) then
             begin
               Exit;
             end;

         // Nova Thread para executar Processo
         vThreadNovaConexao       := TNovaConexao.Create(POSPGWLib.WszTerminalId, POSPGWLib.WszModel, POSPGWLib.WszMAC, POSPGWLib.WszSerNum);

         // Inicia
         vThreadNovaConexao.Start;

         Sleep(300);

      end;


 end;



//=======================================================
// Sincronização Thread de Aguardar caso seja necessário
//==============================================
procedure TAguardaConexao.Sincronizar;
begin
 //FMemo.Lines.Add(Self.FAux);
end;

//==============================================
// Finaliza Thread de Aguardar
//==============================================
procedure TAguardaConexao.Terminate;
begin

  Terminate;

end;


//==========================================
// Botão Iniciar
// Inicia Thread que Aguarda Novas Conexões
//==========================================
procedure TFPrincipal.Button1Click(Sender: TObject);
var
 vThreadAguarde : TAguardaConexao;
 caminho:string;
 pasta:string;
 Retorno:Integer;
 Wthr:Integer;
begin

    Wfinalizar := 0;

    Button1.Enabled := False;
    Button2.Enabled := True;

    POSPGWLib  := TPOSPGWLib.Create;

    //=========================================
    // Cria Pasta para Log
    //=========================================

    POSPGWLib.pasta := 'PayGoPOS';


    Caminho := ExtractFilePath(ParamStr(0)) + POSPGWLib.pasta;

    if not DirectoryExists(Caminho) then
       begin
         if not CreateDir(Caminho) then
            begin
              ForceDirectories(caminho);
            end;
       end;


       // Metodfo Iniciar Lib

       Retorno := POSPGWLib.Init();
       if Retorno <> POSenums.PTIRET_OK then
          begin
            Exit;
          end;

      //===============

     // Criar Thread Para Aguardar Conexões
     vThreadAguarde       := TAguardaConexao.Create();


     // Iniciar Thread
     vThreadAguarde.Start;





end;

//===============================================
//  Desconecta Thread de Aguardar Novas Conexões
//===============================================

procedure TFPrincipal.Button2Click(Sender: TObject);
begin
  // Indicador para finalizar Thread
  FPrincipal.Wfinalizar := 1;

  // Metodo Finalizar DLL
  POSPGWLib.Finalizar();

  Button2.Enabled := false;
  Button1.Enabled := True;


end;

//================================
// Limpa Log da Aplicação
//================================

procedure TFPrincipal.Button3Click(Sender: TObject);
begin

     Memo1.Clear;

end;

//================================
// Construtor de Main
//================================

constructor TFPrincipal.Create;
begin

    POSenums   := TCPOSEnums.Create;

end;

//================================
// Destrutor de Main
//================================

destructor TFPrincipal.Destroy;
begin

  inherited;
end;



//================================
// Encerra Aplicação
//================================
procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    Application.Terminate;

end;


//==================================================
// Atualiza Informações de Nome/Versão da Aplicação
//==================================================
procedure TFPrincipal.FormCreate(Sender: TObject);
var
 caminho:string;
 pasta:string;
 Retorno:Integer;
 Wthr:Integer;
begin

      //=================================================
      //  Atualiza Form Inicial com Dados da Aplicação
      //=================================================

      Label1.Caption := 'Versão : ' + '  ' + eCclasse.PGWEBLIBTEST_VERSION;
      Label3.Caption := 'Nome   : ' + '  ' + eCclasse.PGWEBLIBTEST_AUTNAME;

end;

end.
