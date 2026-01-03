program sssds;

uses
  Vcl.Forms,
  Main in 'Main.pas' {TMainForm},
  GDIPlusImport in 'GDIPlusImport.pas',
  ShadowForm in 'ShadowForm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
