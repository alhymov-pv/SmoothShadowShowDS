unit GDIPlusImport;

interface

uses
  Windows, Classes, SysUtils, Graphics;

type
  Status = (
    Ok = 0,
    GenericError = 1,
    InvalidParameter = 2,
    OutOfMemory = 3,
    ObjectBusy = 4,
    InsufficientBuffer = 5,
    NotImplemented = 6,
    Win32Error = 7,
    WrongState = 8,
    Aborted = 9,
    FileNotFound = 10,
    ValueOverflow = 11,
    AccessDenied = 12,
    UnknownImageFormat = 13,
    FontFamilyNotFound = 14,
    FontStyleNotFound = 15,
    NotTrueTypeFont = 16,
    UnsupportedGdiplusVersion = 17,
    GdiplusNotInitialized = 18,
    PropertyNotFound = 19,
    PropertyNotSupported = 20
  );

  Color = DWORD;
  PColor = ^Color;

  TGPColor = packed record
    Blue: Byte;
    Green: Byte;
    Red: Byte;
    Alpha: Byte;
  end;
  PGPColor = ^TGPColor;

  TGPColorArray = array of TGPColor;

  WrapMode = (
    WrapModeTile = 0,
    WrapModeTileFlipX = 1,
    WrapModeTileFlipY = 2,
    WrapModeTileFlipXY = 3,
    WrapModeClamp = 4
  );

  TGdiplusBase = class
  public
    destructor Destroy; override;
  end;

  GpGraphics = Pointer;
  GpBrush = Pointer;
  GpPathGradient = Pointer;
  GpPath = Pointer;

  PGdiPointF = ^TGdiPointF;
  TGdiPointF = packed record
    X: Single;
    Y: Single;
  end;

  TGdiPointFArray = array of TGdiPointF;

  TGPGraphics = class(TGdiplusBase)
  private
    FNativeGraphics: GpGraphics;
  public
    constructor Create(hdc: HDC); overload;
    constructor Create(hwnd: HWND); overload;
    destructor Destroy; override;
    procedure Clear(color: Color);
    procedure FillRectangle(brush: GpBrush; x, y, width, height: Integer); overload;
    procedure FillRectangle(brush: GpBrush; x, y, width, height: Single); overload;
    function GetHDC: HDC;
    procedure ReleaseHDC(hdc: HDC);
  end;

  TGPPathGradientBrush = class(TGdiplusBase)
  private
    FNativeBrush: GpPathGradient;
  public
    constructor Create(points: PGdiPointF; count: Integer);
    destructor Destroy; override;
    procedure SetCenterColor(color: Color);
    procedure SetSurroundColors(colors: TGPColorArray);
    procedure SetCenterPoint(point: TGdiPointF);
    function GetNativeBrush: GpBrush;
  end;

  TGPPath = class(TGdiplusBase)
  private
    FNativePath: GpPath;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddEllipse(x, y, width, height: Single);
    function GetNativePath: GpPath;
  end;

// GDI+ API Functions
function GdipCreateFromHDC(hdc: HDC; out graphics: GpGraphics): Status; stdcall;
function GdipDeleteGraphics(graphics: GpGraphics): Status; stdcall;
function GdipGraphicsClear(graphics: GpGraphics; color: Color): Status; stdcall;
function GdipFillRectangleI(graphics: GpGraphics; brush: GpBrush; x, y, width, height: Integer): Status; stdcall;
function GdipFillRectangle(graphics: GpGraphics; brush: GpBrush; x, y, width, height: Single): Status; stdcall;
function GdipGetDC(graphics: GpGraphics; var hdc: HDC): Status; stdcall;
function GdipReleaseDC(graphics: GpGraphics; hdc: HDC): Status; stdcall;
function GdipCreatePathGradient(points: PGdiPointF; count: Integer; wrapMode: WrapMode; out polyGradient: GpPathGradient): Status; stdcall;
function GdipSetPathGradientCenterColor(brush: GpPathGradient; colors: Color): Status; stdcall;
function GdipSetPathGradientSurroundColorsWithCount(brush: GpPathGradient; colors: PColor; var count: Integer): Status; stdcall;
function GdipSetPathGradientCenterPoint(brush: GpPathGradient; point: PGdiPointF): Status; stdcall;
function GdipDeleteBrush(brush: GpBrush): Status; stdcall;
function GdipCreatePath(fillMode: Integer; out path: GpPath): Status; stdcall;
function GdipAddPathEllipse(path: GpPath; x, y, width, height: Single): Status; stdcall;
function GdipDeletePath(path: GpPath): Status; stdcall;
function GdipCreateFromHWND(hwnd: HWND; out graphics: GpGraphics): Status; stdcall;

// GDI+ Startup/Shutdown
function GdiplusStartup(out token: ULONG; input: Pointer; output: Pointer): Status; stdcall;
procedure GdiplusShutdown(token: ULONG); stdcall;

var
  GdiplusToken: ULONG;

implementation

const
  GDIPlusDLL = 'gdiplus.dll';

// GDI+ API Function Declarations
function GdipCreateFromHDC; external GDIPlusDLL name 'GdipCreateFromHDC';
function GdipDeleteGraphics; external GDIPlusDLL name 'GdipDeleteGraphics';
function GdipGraphicsClear; external GDIPlusDLL name 'GdipGraphicsClear';
function GdipFillRectangleI; external GDIPlusDLL name 'GdipFillRectangleI';
function GdipFillRectangle; external GDIPlusDLL name 'GdipFillRectangle';
function GdipGetDC; external GDIPlusDLL name 'GdipGetDC';
function GdipReleaseDC; external GDIPlusDLL name 'GdipReleaseDC';
function GdipCreatePathGradient; external GDIPlusDLL name 'GdipCreatePathGradient';
function GdipSetPathGradientCenterColor; external GDIPlusDLL name 'GdipSetPathGradientCenterColor';
function GdipSetPathGradientSurroundColorsWithCount; external GDIPlusDLL name 'GdipSetPathGradientSurroundColorsWithCount';
function GdipSetPathGradientCenterPoint; external GDIPlusDLL name 'GdipSetPathGradientCenterPoint';
function GdipDeleteBrush; external GDIPlusDLL name 'GdipDeleteBrush';
function GdipCreatePath; external GDIPlusDLL name 'GdipCreatePath';
function GdipAddPathEllipse; external GDIPlusDLL name 'GdipAddPathEllipse';
function GdipDeletePath; external GDIPlusDLL name 'GdipDeletePath';
function GdipCreateFromHWND; external GDIPlusDLL name 'GdipCreateFromHWND';
function GdiplusStartup; external GDIPlusDLL name 'GdiplusStartup';
procedure GdiplusShutdown; external GDIPlusDLL name 'GdiplusShutdown';

{ TGdiplusBase }

destructor TGdiplusBase.Destroy;
begin
  inherited;
end;

{ TGPGraphics }

constructor TGPGraphics.Create(hdc: HDC);
begin
  inherited Create;
  GdipCreateFromHDC(hdc, FNativeGraphics);
end;

constructor TGPGraphics.Create(hwnd: HWND);
begin
  inherited Create;
  GdipCreateFromHWND(hwnd, FNativeGraphics);
end;

destructor TGPGraphics.Destroy;
begin
  if FNativeGraphics <> nil then
    GdipDeleteGraphics(FNativeGraphics);
  inherited;
end;

procedure TGPGraphics.Clear(color: Color);
begin
  if FNativeGraphics <> nil then
    GdipGraphicsClear(FNativeGraphics, color);
end;

procedure TGPGraphics.FillRectangle(brush: GpBrush; x, y, width, height: Integer);
begin
  if FNativeGraphics <> nil then
    GdipFillRectangleI(FNativeGraphics, brush, x, y, width, height);
end;

procedure TGPGraphics.FillRectangle(brush: GpBrush; x, y, width, height: Single);
begin
  if FNativeGraphics <> nil then
    GdipFillRectangle(FNativeGraphics, brush, x, y, width, height);
end;

function TGPGraphics.GetHDC: HDC;
var
  tempDC: HDC;
begin
  if FNativeGraphics <> nil then
  begin
    GdipGetDC(FNativeGraphics, tempDC);
    Result := tempDC;
  end
  else
    Result := 0;
end;

procedure TGPGraphics.ReleaseHDC(hdc: HDC);
begin
  if FNativeGraphics <> nil then
    GdipReleaseDC(FNativeGraphics, hdc);
end;

{ TGPPathGradientBrush }

constructor TGPPathGradientBrush.Create(points: PGdiPointF; count: Integer);
begin
  inherited Create;
  GdipCreatePathGradient(points, count, WrapModeClamp, FNativeBrush);
end;

destructor TGPPathGradientBrush.Destroy;
begin
  if FNativeBrush <> nil then
    GdipDeleteBrush(FNativeBrush);
  inherited;
end;

procedure TGPPathGradientBrush.SetCenterColor(color: Color);
begin
  if FNativeBrush <> nil then
    GdipSetPathGradientCenterColor(FNativeBrush, color);
end;

procedure TGPPathGradientBrush.SetSurroundColors(colors: TGPColorArray);
var
  count: Integer;
  colorsDword: array of DWORD;
  i: Integer;
begin
  if (FNativeBrush <> nil) and (Length(colors) > 0) then
  begin
    count := Length(colors);
    SetLength(colorsDword, count);
    for i := 0 to count - 1 do
    begin
      colorsDword[i] := (colors[i].Alpha shl 24) or
                        (colors[i].Red shl 16) or
                        (colors[i].Green shl 8) or
                        colors[i].Blue;
    end;
    GdipSetPathGradientSurroundColorsWithCount(FNativeBrush, @colorsDword[0], count);
  end;
end;

procedure TGPPathGradientBrush.SetCenterPoint(point: TGdiPointF);
begin
  if FNativeBrush <> nil then
    GdipSetPathGradientCenterPoint(FNativeBrush, @point);
end;

function TGPPathGradientBrush.GetNativeBrush: GpBrush;
begin
  Result := FNativeBrush;
end;

{ TGPPath }

constructor TGPPath.Create;
begin
  inherited Create;
  GdipCreatePath(0, FNativePath); // 0 = FillModeAlternate
end;

destructor TGPPath.Destroy;
begin
  if FNativePath <> nil then
    GdipDeletePath(FNativePath);
  inherited;
end;

procedure TGPPath.AddEllipse(x, y, width, height: Single);
begin
  if FNativePath <> nil then
    GdipAddPathEllipse(FNativePath, x, y, width, height);
end;

function TGPPath.GetNativePath: GpPath;
begin
  Result := FNativePath;
end;

initialization
  // Initialize GDI+
  GdiplusStartup(GdiplusToken, nil, nil);

finalization
  // Shutdown GDI+
  GdiplusShutdown(GdiplusToken);

end.
