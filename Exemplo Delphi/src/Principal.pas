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
    //constructor Create(AMemo: TMemo); reintroduce;
    constructor Create(NszTerminalId:AnsiString; NszModel:AnsiString; NszMAC: AnsiString; NszSerNum: AnsiString);
    //constructor Create(); reintroduce;
    procedure Execute; override;
    procedure Sincronizar;
  end;


Type
TAguardaConexao = class(TThread)
  private
     FAux: String;
     //FMemo: TMemo;
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
  end;



type
  TFPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Venda1: TMenuItem;
    Cancelamento1: TMenuItem;
    N3: TMenuItem;
    DesconectarPOS1: TMenuItem;
    N4: TMenuItem;
    Button2: TButton;
    Button1: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    ConectarAutomao1: TMenuItem;
    N2: TMenuItem;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ConectarAutomao1Click(Sender: TObject);
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

    Constructor Create;             // declaração do metodo construtor

    Destructor  Destroy; Override; // declaração do metodo destrutor

  end;

var
  FPrincipal: TFPrincipal;

  iRet:Integer;



implementation

{$R *.dfm}


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

// Atualiza o Form
procedure TNovaConexao.Sincronizar;
begin
 // FMemo.Lines.Add(Self.FAux);
end;




constructor TAguardaConexao.Create;
begin

   inherited Create(True);

   // Libera da memoria o objeto após terminar.
   Self.FreeOnTerminate := True;

   FAux := '';
//   FMemo := AMemo;

end;


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

         // Nova Thread
         vThreadNovaConexao       := TNovaConexao.Create(POSPGWLib.WszTerminalId, POSPGWLib.WszModel, POSPGWLib.WszMAC, POSPGWLib.WszSerNum);

         // Inicia
         vThreadNovaConexao.Start;


         Sleep(300);


      end;


 end;






procedure TAguardaConexao.Sincronizar;
begin
 //FMemo.Lines.Add(Self.FAux);
end;





procedure TFPrincipal.Button1Click(Sender: TObject);
var
 vThreadAguarde : TAguardaConexao;
 caminho:string;
 pasta:string;
 Retorno:Integer;
 Wthr:Integer;
begin

    Button1.Enabled := False;
    Button2.Enabled := True;

    //=============================
    // Init esta no create do Form
    //=============================

     // Criar Thread de Aguarde
     vThreadAguarde       := TAguardaConexao.Create();

     // Iniciar
     vThreadAguarde.Start;



end;


procedure TFPrincipal.Button2Click(Sender: TObject);
begin

  POSPGWLib.Finalizar();

  Button2.Enabled := false;
  Button1.Enabled := True;


end;

procedure TFPrincipal.ConectarAutomao1Click(Sender: TObject);
var
 vThreadAguarde : TAguardaConexao;
 caminho:string;
 pasta:string;
 Retorno:Integer;
 Wthr:Integer;
begin


end;

constructor TFPrincipal.Create;
begin

    POSenums   := TCPOSEnums.Create;

end;

destructor TFPrincipal.Destroy;
begin

  inherited;
end;




procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    Application.Terminate;

end;

procedure TFPrincipal.FormCreate(Sender: TObject);
var
 caminho:string;
 pasta:string;
 Retorno:Integer;
 Wthr:Integer;
begin


    POSPGWLib  := TPOSPGWLib.Create;

    POSPGWLib.pasta := 'PayGoPOS';


    Caminho := ExtractFilePath(ParamStr(0)) + POSPGWLib.pasta;

    if not DirectoryExists(Caminho) then
       begin
         if not CreateDir(Caminho) then
            begin
              ForceDirectories(caminho);
            end;
       end;

       Retorno := POSPGWLib.Init();
       if Retorno <> POSenums.PTIRET_OK then
          begin
            Exit;
          end;


      //=================================================
      //  Atualiza Form Inicial com Dados da Aplicação
      //=================================================

      Label1.Caption := 'Versão : ' + '  ' + eCclasse.PGWEBLIBTEST_VERSION;
      Label3.Caption := 'Nome   : ' + '  ' + eCclasse.PGWEBLIBTEST_AUTNAME;

end;

end.


