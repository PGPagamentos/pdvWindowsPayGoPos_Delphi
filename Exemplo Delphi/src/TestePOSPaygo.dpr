program TestePOSPaygo;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {Form1},
  uPOSPGWLib in 'uPOSPGWLib.pas',
  uPOSEnums in 'uPOSEnums.pas',
  uLib in 'uLib.pas',
  uLib02 in 'uLib02.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
