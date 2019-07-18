program TestePOSPaygo;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {FPrincipal},
  uPOSPGWLib in 'uPOSPGWLib.pas',
  uPOSEnums in 'uPOSEnums.pas',
  uLib in 'uLib.pas',
  uLib02 in 'uLib02.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.Run;
end.
