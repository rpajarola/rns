{ SDL Graph }

Unit Graph;

Interface

Const
    { GraphResult error return codes: }
    grOk = 0;
    grNoInitGraph = -1;
    grNotDetected = -2;
    grFileNotFound = -3;
    grInvalidDriver = -4;
    grNoLoadMem = -5;
    grNoScanMem = -6;
    grNoFloodMem = -7;
    grFontNotFound = -8;
    grNoFontMem = -9;
    grInvalidMode = -10;
    grError = -11;   { generic error }
    grIOerror = -12;
    grInvalidFont = -13;
    grInvalidFontNum = -14;
    grInvalidVersion = -18;

    { define graphics drivers }
    CurrentDriver = -128; { passed to GetModeRange }
    Detect = 0;    { requests autodetection }
    CGA = 1;
    MCGA = 2;
    EGA = 3;
    EGA64 = 4;
    EGAMono = 5;
    IBM8514 = 6;
    HercMono = 7;
    ATT400 = 8;
    VGA = 9;
    PC3270 = 10;

    { graphics modes for each driver }
    CGAC0 = 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
    CGAC1 = 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
    CGAC2 = 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
    CGAC3 = 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
    CGAHi = 4;  { 640x200 1 page }
    MCGAC0 = 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
    MCGAC1 = 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
    MCGAC2 = 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
    MCGAC3 = 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
    MCGAMed = 4;  { 640x200 1 page }
    MCGAHi = 5;  { 640x480 1 page }
    EGALo = 0;  { 640x200 16 color 4 page }
    EGAHi = 1;  { 640x350 16 color 2 page }
    EGA64Lo = 0;  { 640x200 16 color 1 page }
    EGA64Hi = 1;  { 640x350 4 color  1 page }
    EGAMonoHi = 3;  { 640x350 64K on card, 1 page; 256K on card, 2 page }
    HercMonoHi = 0;  { 720x348 2 page }
    ATT400C0 = 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
    ATT400C1 = 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
    ATT400C2 = 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
    ATT400C3 = 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
    ATT400Med = 4;  { 640x200 1 page }
    ATT400Hi = 5;  { 640x400 1 page }
    VGALo = 0;  { 640x200 16 color 4 page }
    VGAMed = 1;  { 640x350 16 color 2 page }
    VGAHi = 2;  { 640x480 16 color 1 page }
    PC3270Hi = 0;  { 720x350 1 page }
    IBM8514LO = 0;  { 640x480 256 colors }
    IBM8514HI = 1;  { 1024x768 256 colors }

    { Colors for SetPalette and SetAllPalette: }
    Black = 0;
    Blue = 1;
    Green = 2;
    Cyan = 3;
    Red = 4;
    Magenta = 5;
    Brown = 6;
    LightGray = 7;
    DarkGray = 8;
    LightBlue = 9;
    LightGreen = 10;
    LightCyan = 11;
    LightRed = 12;
    LightMagenta = 13;
    Yellow = 14;
    White = 15;

    { colors for 8514 to set standard EGA colors w/o knowing their values }
    EGABlack = 0;       { dark colors }
    EGABlue = 1;
    EGAGreen = 2;
    EGACyan = 3;
    EGARed = 4;
    EGAMagenta = 5;
    EGABrown = 20;
    EGALightgray = 7;
    EGADarkgray = 56;      { light colors }
    EGALightblue = 57;
    EGALightgreen = 58;
    EGALightcyan = 59;
    EGALightred = 60;
    EGALightmagenta = 61;
    EGAYellow = 62;
    EGAWhite = 63;

    { Line styles and widths for Get/SetLineStyle: }
    SolidLn = 0;
    DottedLn = 1;
    CenterLn = 2;
    DashedLn = 3;
    UserBitLn = 4;       { User-defined line style }

    NormWidth = 1;
    ThickWidth = 3;

    { Set/GetTextStyle constants: }
    DefaultFont = 0;    { 8x8 bit mapped font }
    TriplexFont = 1;    { "Stroked" fonts }
    SmallFont = 2;
    SansSerifFont = 3;
    GothicFont = 4;

    HorizDir = 0;       { left to right }
    VertDir  = 1;       { bottom to top }

    UserCharSize = 0;     { user-defined char size }

    { Clipping constants: }
    ClipOn = true;
    ClipOff = false;

    { Bar3D constants: }
    TopOn = true;
    TopOff = false;

    { Fill patterns for Get/SetFillStyle: }
    EmptyFill = 0;  { fills area in background color }
    SolidFill = 1;  { fills area in solid fill color }
    LineFill  = 2;  { --- fill }
    LtSlashFill = 3;  { /// fill }
    SlashFill = 4;  { /// fill with thick lines }
    BkSlashFill = 5;  { \\\ fill with thick lines }
    LtBkSlashFill = 6;  { \\\ fill }
    HatchFill = 7;  { light hatch fill }
    XHatchFill = 8;  { heavy cross hatch fill }
    InterleaveFill = 9;  { interleaving line fill }
    WideDotFill = 10; { Widely spaced dot fill }
    CloseDotFill = 11; { Closely spaced dot fill }
    UserFill  = 12; { user defined fill }

    { BitBlt operators for PutImage: }
    NormalPut = 0;    { MOV }       { left for 1.0 compatibility }
    CopyPut = 0;    { MOV }
    XORPut = 1;    { XOR }
    OrPut = 2;    { OR  }
    AndPut = 3;    { AND }
    NotPut = 4;    { NOT }

    { Horizontal and vertical justification for SetTextJustify: }
    LeftText = 0;
    CenterText = 1;
    RightText = 2;

    BottomText = 0;
    { CenterText = 1; already defined above }
    TopText = 2;


Const
    MaxColors = 15;

Type
    PaletteType = Record
        Size: byte;
        Colors: Array[0..MaxColors] Of shortint;
    End;

    LineSettingsType = Record
        LineStyle: word;
        Pattern: word;
        Thickness: word;
    End;

    TextSettingsType = Record
        Font: word;
        Direction: word;
        CharSize: word;
        Horiz: word;
        Vert: word;
    End;

    FillSettingsType = Record               { Pre-defined fill style }
        Pattern: word;
        Color: word;
    End;

    FillPatternType = Array[1..8] Of byte;  { User defined fill style }

    PointType = Record
        X, Y: integer;
    End;

    ViewPortType = Record
        x1, y1, x2, y2: integer;
        Clip: boolean;
    End;

    ArcCoordsType = Record
        X, Y: integer;
        Xstart, Ystart: integer;
        Xend, Yend: integer;
    End;


Var
    GraphGetMemPtr: Pointer;   { allows user to steal heap allocation }
    GraphFreeMemPtr: Pointer;   { allows user to steal heap de-allocation }

{ *** high-level error handling *** }
Function GraphErrorMsg(ErrorCode: integer): String;
Function GraphResult: integer;

{ *** detection, initialization and crt mode routines *** }
Procedure DetectGraph(Var GraphDriver, GraphMode: integer);
Function GetDriverName: string;

Procedure InitGraph(Var GraphDriver: integer;
    Var GraphMode: integer;
    PathToDriver: String);

Function RegisterBGIfont(Font: pointer): integer;
Function RegisterBGIdriver(Driver: pointer): integer;
Function InstallUserDriver(DriverFileName: string;
    AutoDetectPtr: pointer): integer;
Function InstallUserFont(FontFileName: string): integer;
Procedure SetGraphBufSize(BufSize: word);
Function GetMaxMode: integer;
Procedure GetModeRange(GraphDriver: integer; Var LoMode, HiMode: integer);
Function GetModeName(GraphMode: integer): string;
Procedure SetGraphMode(Mode: integer);
Function GetGraphMode: integer;
Procedure GraphDefaults;
Procedure RestoreCrtMode;
Procedure CloseGraph;

Function GetX: integer;
Function GetY: integer;
Function GetMaxX: integer;
Function GetMaxY: integer;

{ *** Screen, viewport, page routines *** }
Procedure ClearDevice;
Procedure SetViewPort(x1, y1, x2, y2: integer; Clip: boolean);
Procedure GetViewSettings(Var ViewPort: ViewPortType);
Procedure ClearViewPort;
Procedure SetVisualPage(Page: word);
Procedure SetActivePage(Page: word);

{ *** point-oriented routines *** }
Procedure PutPixel(X, Y: integer; Pixel: word);
Function GetPixel(X, Y: integer): word;

{ *** line-oriented routines *** }
Procedure SetWriteMode(WriteMode: integer);
Procedure LineTo(X, Y: integer);
Procedure LineRel(Dx, Dy: integer);
Procedure MoveTo(X, Y: integer);
Procedure MoveRel(Dx, Dy: integer);
Procedure Line(x1, y1, x2, y2: integer);
Procedure GetLineSettings(Var LineInfo: LineSettingsType);
Procedure SetLineStyle(LineStyle: word;
    Pattern: word;
    Thickness: word);

{ *** polygon, fills and figures *** }
Procedure Rectangle(x1, y1, x2, y2: integer);
Procedure Bar(x1, y1, x2, y2: integer);
Procedure Bar3D(x1, y1, x2, y2: integer; Depth: word; Top: boolean);
Procedure DrawPoly(NumPoints: word; Var PolyPoints);
Procedure FillPoly(NumPoints: word; Var PolyPoints);
Procedure GetFillSettings(Var FillInfo: FillSettingsType);
Procedure GetFillPattern(Var FillPattern: FillPatternType);
Procedure SetFillStyle(Pattern: word; Color: word);
Procedure SetFillPattern(Pattern: FillPatternType; Color: word);
Procedure FloodFill(X, Y: integer; Border: word);

{ *** arc, circle, and other curves *** }
Procedure Arc(X, Y: integer; StAngle, EndAngle, Radius: word);
Procedure GetArcCoords(Var ArcCoords: ArcCoordsType);
Procedure Circle(X, Y: integer; Radius: word);
Procedure Ellipse(X, Y: integer;
    StAngle, EndAngle: word;
    XRadius, YRadius: word);
Procedure FillEllipse(X, Y: integer;
    XRadius, YRadius: word);
Procedure GetAspectRatio(Var Xasp, Yasp: word);
Procedure SetAspectRatio(Xasp, Yasp: word);
Procedure PieSlice(X, Y: integer; StAngle, EndAngle, Radius: word);
Procedure Sector(X, Y: Integer;
    StAngle, EndAngle,
    XRadius, YRadius: word);


{ *** color and palette routines *** }
Procedure SetBkColor(ColorNum: word);
Procedure SetColor(Color: word);
Function GetBkColor: word;
Function GetColor: word;
Procedure SetAllPalette(Var Palette);
Procedure SetPalette(ColorNum: word; Color: shortint);
Procedure GetPalette(Var Palette: PaletteType);
Function GetPaletteSize: integer;
Procedure GetDefaultPalette(Var Palette: PaletteType);
Function GetMaxColor: word;
Procedure SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue: integer);

{ *** bit-image routines *** }
Function ImageSize(x1, y1, x2, y2: integer): word;
Procedure GetImage(x1, y1, x2, y2: integer; Var BitMap);
Procedure PutImage(X, Y: integer; Var BitMap; BitBlt: word);

{ *** text routines *** }
Procedure GetTextSettings(Var TextInfo: TextSettingsType);
Procedure OutText(TextString: string);
Procedure OutTextXY(X, Y: integer; TextString: string);
Procedure SetTextJustify(Horiz, Vert: word);
Procedure SetTextStyle(Font, Direction: word; CharSize: word);
Procedure SetUserCharSize(MultX, DivX, MultY, DivY: word);
Function TextHeight(TextString: string): word;
Function TextWidth(TextString: string): word;


