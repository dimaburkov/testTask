program Project1;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  EditQty in 'EditQty.pas' {FEditQty};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFEditQty, FEditQty);
  Application.Run;
end.
