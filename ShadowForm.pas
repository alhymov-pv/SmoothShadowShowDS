unit ShadowForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, GDIPlusImport, ExtCtrls, StdCtrls;

type
  TGradientShape = (gsPillow, gsSphere, gsCone);

  // Класс для потока анимации
  TAnimationThread = class(TThread)
  private
    FShadowForm: TForm;
    FIsFadeIn: Boolean;
    FMaxOpacity: Byte;
    FDuration: Cardinal;
    FOpacityToSet: Byte;
    procedure UpdateOpacityProc;
    procedure CloseFormProc;
  protected
    procedure Execute; override;
  public
    constructor Create(ShadowForm: TForm; IsFadeIn: Boolean; MaxOpacity: Byte; Duration: Cardinal);
  end;

  // Класс для потока с опциями
  TOptionsThread = class(TThread)
  private
    FShadowForm: TForm;
    FResult: TModalResult;
    FFinished: Boolean;
    procedure ShowOptionsFormProc;
  protected
    procedure Execute; override;
  public
    constructor Create(ShadowForm: TForm);
    property Result: TModalResult read FResult;
    property Finished: Boolean read FFinished;
  end;

  TShadowForm = class(TForm)
  private
    FMaxOpacity: Byte;
    FCurrentOpacity: Byte;
    FShowTime: Cardinal;
    FIsShowing: Boolean;
    FGradientShape: TGradientShape;
    FOptionsResult: TModalResult;
    FOptionsThread: TOptionsThread;
    FAnimationThread: TAnimationThread;

    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure FormShow(Sender: TObject);
    procedure StartFadeInAnimation;
    procedure StartFadeOutAnimation;
    procedure OnOptionsThreadTerminate(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateOpacity(Opacity: Byte);
    function Execute(ParentHandle: HWND; GradientShape: TGradientShape = gsSphere;
      MaxOpacity: Byte = 128; ShowDuration: Cardinal = 2500): TModalResult;
  end;

implementation

{ TAnimationThread }

constructor TAnimationThread.Create(ShadowForm: TForm; IsFadeIn: Boolean; MaxOpacity: Byte; Duration: Cardinal);
begin
  inherited Create(True); // Создаем приостановленным
  FreeOnTerminate := False;
  FShadowForm := ShadowForm;
  FIsFadeIn := IsFadeIn;
  FMaxOpacity := MaxOpacity;
  FDuration := Duration;
end;

procedure TAnimationThread.UpdateOpacityProc;
begin
  if Assigned(FShadowForm) and (FShadowForm is TShadowForm) then
    TShadowForm(FShadowForm).UpdateOpacity(FOpacityToSet);
end;

procedure TAnimationThread.CloseFormProc;
begin
  if Assigned(FShadowForm) and not Application.Terminated then
    FShadowForm.Close;
end;

procedure TAnimationThread.Execute;
var
  StartTime: Cardinal;
  Elapsed: Cardinal;
  Opacity: Byte;
  i, Steps: Integer;
  StepDelay: Cardinal;
begin
  if FIsFadeIn then
  begin
    // Анимация появления
    StartTime := GetTickCount;
    Steps := 100; // Количество шагов для плавности
    StepDelay := FDuration div Steps;

    for i := 0 to Steps do
    begin
      if Terminated then Break;

      if i > 0 then
        Sleep(StepDelay);

      Elapsed := GetTickCount - StartTime;
      if Elapsed >= FDuration then
      begin
        Opacity := FMaxOpacity;
      end
      else
      begin
        // Линейная интерполяция прозрачности
        Opacity := Round(Elapsed / FDuration * FMaxOpacity);
      end;

      FOpacityToSet := Opacity;
      Synchronize(UpdateOpacityProc);

      if Elapsed >= FDuration then
        Break;
    end;
  end
  else
  begin
    // Анимация исчезновения (500 мс)
    Steps := 10;
    StepDelay := 50; // 10 * 50 = 500 мс

    for i := 1 to Steps do
    begin
      if Terminated then Break;

      Sleep(StepDelay);

      Opacity := FMaxOpacity - Round(FMaxOpacity * (i / Steps));
      if Opacity < 0 then Opacity := 0;

      FOpacityToSet := Opacity;
      Synchronize(UpdateOpacityProc);
    end;

    // Закрываем форму
    if not Terminated then
    begin
      Synchronize(CloseFormProc);
    end;
  end;
end;

{ TOptionsThread }

constructor TOptionsThread.Create(ShadowForm: TForm);
begin
  inherited Create(True); // Создаем приостановленным
  FreeOnTerminate := False;
  FShadowForm := ShadowForm;
  FFinished := False;
end;

procedure TOptionsThread.ShowOptionsFormProc;
var
  OptionsForm: TForm;
  ComboBox: TComboBox;
  CheckBox: TCheckBox;
  OKBtn, CancelBtn: TButton;
begin
  // Создаем форму опций
  OptionsForm := TForm.CreateNew(nil);
  try
    OptionsForm.BorderStyle := bsDialog;
    OptionsForm.Caption := 'Опции';
    OptionsForm.Position := poScreenCenter;
    OptionsForm.Width := 300;
    OptionsForm.Height := 200;

    // Галочка
    CheckBox := TCheckBox.Create(OptionsForm);
    CheckBox.Parent := OptionsForm;
    CheckBox.Caption := 'Включить опцию';
    CheckBox.Left := 20;
    CheckBox.Top := 20;

    // Выпадающий список
    ComboBox := TComboBox.Create(OptionsForm);
    ComboBox.Parent := OptionsForm;
    ComboBox.Left := 20;
    ComboBox.Top := 50;
    ComboBox.Width := 150;
    ComboBox.Style := csDropDownList;
    ComboBox.Items.Add('Вариант 1');
    ComboBox.Items.Add('Вариант 2');
    ComboBox.Items.Add('Вариант 3');
    ComboBox.ItemIndex := 0;

    // Кнопка OK
    OKBtn := TButton.Create(OptionsForm);
    OKBtn.Parent := OptionsForm;
    OKBtn.Caption := 'OK';
    OKBtn.ModalResult := mrOk;
    OKBtn.Left := OptionsForm.Width - 160;
    OKBtn.Top := OptionsForm.Height - 60;

    // Кнопка Отмена
    CancelBtn := TButton.Create(OptionsForm);
    CancelBtn.Parent := OptionsForm;
    CancelBtn.Caption := 'Отмена';
    CancelBtn.ModalResult := mrCancel;
    CancelBtn.Left := OptionsForm.Width - 80;
    CancelBtn.Top := OptionsForm.Height - 60;

    // Показываем форму опций
    FResult := OptionsForm.ShowModal;

  finally
    OptionsForm.Free;
  end;
end;

procedure TOptionsThread.Execute;
begin
  Synchronize(ShowOptionsFormProc);
  FFinished := True;
end;

{ TShadowForm }

constructor TShadowForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);

  // Убираем рамку и заголовок
  BorderStyle := bsNone;

  // Прозрачность по умолчанию
  AlphaBlend := True;
  AlphaBlendValue := 0;

  // Назначаем обработчик показа формы
  OnShow := FormShow;

  FCurrentOpacity := 0;
  FMaxOpacity := 128;
  FShowTime := 2500;
  FIsShowing := True;
end;

procedure TShadowForm.FormShow(Sender: TObject);
begin
  // При показе формы запускаем анимацию появления
  StartFadeInAnimation;

  // Создаем поток для формы опций
  FOptionsThread := TOptionsThread.Create(Self);
  FOptionsThread.OnTerminate := OnOptionsThreadTerminate;
  FOptionsThread.Resume;
end;

procedure TShadowForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  // Делаем окно слоистым для поддержки альфа-смешивания
  Params.ExStyle := Params.ExStyle or WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_TOOLWINDOW;
  Params.WndParent := Application.Handle;
  Params.Style := WS_POPUP;
end;

destructor TShadowForm.Destroy;
begin
  // Останавливаем потоки
  if Assigned(FAnimationThread) then
  begin
    FAnimationThread.Terminate;
    FAnimationThread.WaitFor;
    FreeAndNil(FAnimationThread);
  end;

  if Assigned(FOptionsThread) then
  begin
    FOptionsThread.Terminate;
    FOptionsThread.WaitFor;
    FreeAndNil(FOptionsThread);
  end;

  inherited;
end;

procedure TShadowForm.DoClose(var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TShadowForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  // Запрещаем стандартную очистку фона
  Message.Result := 1;
end;

procedure TShadowForm.WMNCHitTest(var Message: TWMNCHitTest);
begin
  // Пропускаем все клики через окно
  Message.Result := HTTRANSPARENT;
end;

procedure TShadowForm.UpdateOpacity(Opacity: Byte);
begin
  FCurrentOpacity := Opacity;
  AlphaBlendValue := Opacity;

  // Перерисовываем окно
  InvalidateRect(Handle, nil, False);
  UpdateWindow(Handle);
end;

procedure TShadowForm.WMPaint(var Message: TWMPaint);
var
  PS: TPaintStruct;
  Graphics: TGPGraphics;
  Brush: TGPPathGradientBrush;
  Points: array[0..3] of TGdiPointF;
  CenterColor, SurroundColor: TGPColor;
  Center: TGdiPointF;
  I: Integer;
  Colors: TGPColorArray;
  ColorDWORD: DWORD;
begin
  BeginPaint(Handle, PS);
  try
    Graphics := TGPGraphics.Create(Canvas.Handle);
    try
      // Очищаем фон полностью прозрачным
      Graphics.Clear($00000000);

      if FCurrentOpacity = 0 then Exit;

      // Создаем градиентную кисть
      Points[0].X := 0;
      Points[0].Y := 0;
      Points[1].X := ClientWidth;
      Points[1].Y := 0;
      Points[2].X := ClientWidth;
      Points[2].Y := ClientHeight;
      Points[3].X := 0;
      Points[3].Y := ClientHeight;

      Brush := TGPPathGradientBrush.Create(@Points[0], 4);
      try
        // Устанавливаем цвета
        CenterColor.Alpha := FCurrentOpacity;
        CenterColor.Red := 0;
        CenterColor.Green := 0;
        CenterColor.Blue := 0;

        SurroundColor.Alpha := 0;
        SurroundColor.Red := 0;
        SurroundColor.Green := 0;
        SurroundColor.Blue := 0;

        ColorDWORD := (CenterColor.Alpha shl 24) or
                     (CenterColor.Red shl 16) or
                     (CenterColor.Green shl 8) or
                     CenterColor.Blue;
        Brush.SetCenterColor(ColorDWORD);

        // Устанавливаем окружающие цвета
        SetLength(Colors, 4);
        for I := 0 to 3 do
          Colors[I] := SurroundColor;
        Brush.SetSurroundColors(Colors);

        // Устанавливаем центр градиента
        Center.X := ClientWidth / 2;
        Center.Y := ClientHeight / 2;
        Brush.SetCenterPoint(Center);

        // Заливаем всю клиентскую область
        Graphics.FillRectangle(Brush.GetNativeBrush, 0, 0, ClientWidth, ClientHeight);
      finally
        Brush.Free;
      end;
    finally
      Graphics.Free;
    end;
  finally
    EndPaint(Handle, PS);
  end;
end;

procedure TShadowForm.StartFadeInAnimation;
begin
  if Assigned(FAnimationThread) then
  begin
    FAnimationThread.Terminate;
    FAnimationThread.WaitFor;
    FreeAndNil(FAnimationThread);
  end;

  FAnimationThread := TAnimationThread.Create(Self, True, FMaxOpacity, FShowTime);
  FAnimationThread.Resume;
end;

procedure TShadowForm.StartFadeOutAnimation;
begin
  if Assigned(FAnimationThread) then
  begin
    FAnimationThread.Terminate;
    FAnimationThread.WaitFor;
    FreeAndNil(FAnimationThread);
  end;

  FAnimationThread := TAnimationThread.Create(Self, False, FMaxOpacity, 500);
  FAnimationThread.Resume;
end;

procedure TShadowForm.OnOptionsThreadTerminate(Sender: TObject);
begin
  // Этот метод вызывается когда поток с опциями завершился
  if Assigned(FOptionsThread) then
  begin
    FOptionsResult := FOptionsThread.Result;

    // Если опции закрыли раньше времени анимации, останавливаем показ
    if FIsShowing then
    begin
      FIsShowing := False;
      StartFadeOutAnimation;
    end;
  end;
end;

function TShadowForm.Execute(ParentHandle: HWND; GradientShape: TGradientShape;
  MaxOpacity: Byte; ShowDuration: Cardinal): TModalResult;
var
  ParentRect: TRect;
  ParentWindow: HWND;
  ScreenRect: TRect;
begin
  FGradientShape := GradientShape;
  FMaxOpacity := MaxOpacity;
  FShowTime := ShowDuration;

  // Получаем размеры родительского окна
  if ParentHandle = 0 then
    ParentWindow := GetDesktopWindow
  else
    ParentWindow := ParentHandle;

  // Используем Windows API функцию GetClientRect
  Windows.GetClientRect(ParentWindow, ParentRect);

  // Преобразуем координаты клиентской области в экранные
  // В Delphi 6 MapWindowPoints принимает 3 параметра
  Windows.MapWindowPoints(ParentWindow, 0, ParentRect, 2);

  // Если родитель - десктоп, используем координаты экрана
  if ParentWindow = GetDesktopWindow then
  begin
    // Альтернативный способ получения размеров экрана
    ScreenRect.Left := 0;
    ScreenRect.Top := 0;
    ScreenRect.Right := GetSystemMetrics(SM_CXSCREEN);
    ScreenRect.Bottom := GetSystemMetrics(SM_CYSCREEN);
    ParentRect := ScreenRect;
  end;

  // Устанавливаем размер и позицию тени
  SetBounds(
    ParentRect.Left,
    ParentRect.Top,
    ParentRect.Right - ParentRect.Left,
    ParentRect.Bottom - ParentRect.Top
  );

  // Устанавливаем начальную прозрачность
  UpdateOpacity(0);

  // Показываем тень (при показе запустится анимация и поток с опциями)
  ShowModal;

  // Ждем завершения всех потоков
  if Assigned(FAnimationThread) then
  begin
    FAnimationThread.WaitFor;
    FreeAndNil(FAnimationThread);
  end;

  if Assigned(FOptionsThread) then
  begin
    FOptionsThread.WaitFor;
    FreeAndNil(FOptionsThread);
  end;

  Result := FOptionsResult;
end;

end.
