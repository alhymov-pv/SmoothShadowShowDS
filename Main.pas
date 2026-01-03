unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShadowForm;

type
  TMainForm = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox2: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Типы градиентов
  ComboBox1.Items.Add('Сферический градиент');
  ComboBox1.Items.Add('Подушкообразный градиент');
  ComboBox1.Items.Add('Конусный градиент');
  ComboBox1.ItemIndex := 0;

  // Уровни прозрачности
  ComboBox2.Items.Add('25%');
  ComboBox2.Items.Add('50%');
  ComboBox2.Items.Add('75%');
  ComboBox2.Items.Add('100%');
  ComboBox2.ItemIndex := 1;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  Shadow: TShadowForm;
  Result: TModalResult;
  GradientShape: TGradientShape;
  MaxOpacity: Byte;
begin
  // Выбираем тип градиента
  case ComboBox1.ItemIndex of
    0: GradientShape := gsSphere;
    1: GradientShape := gsPillow;
    2: GradientShape := gsCone;
  else
    GradientShape := gsSphere;
  end;

  // Выбираем уровень прозрачности
  case ComboBox2.ItemIndex of
    0: MaxOpacity := 64;   // 25%
    1: MaxOpacity := 128;  // 50%
    2: MaxOpacity := 192;  // 75%
    3: MaxOpacity := 255;  // 100%
  else
    MaxOpacity := 128;
  end;

  Shadow := TShadowForm.Create(nil);
  try
    // Теперь используем ShowModal вместо Execute
    Result := Shadow.ShowModal;

    if Result = mrOk then
      ShowMessage('Опции подтверждены!')
    else if Result = mrCancel then
      ShowMessage('Опции отменены.')
    else
      ShowMessage('Диалог закрыт с кодом: ' + IntToStr(Result));
  finally
    Shadow.Free;
  end;
end;

end.
