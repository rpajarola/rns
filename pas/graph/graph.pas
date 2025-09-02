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
    CGAC0 = (CGA SHL 8) + 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
    CGAC1 = (CGA SHL 8) + 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
    CGAC2 = (CGA SHL 8) + 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
    CGAC3 = (CGA SHL 8) + 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
    CGAHi = (CGA SHL 8) + 4;  { 640x200 1 page }
    MCGAC0 = (MCGA SHL 8) + 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
    MCGAC1 = (MCGA SHL 8) + 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
    MCGAC2 = (MCGA SHL 8) + 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
    MCGAC3 = (MCGA SHL 8) + 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
    MCGAMed = (MCGA SHL 8) + 4;  { 640x200 1 page }
    MCGAHi = (MCGA SHL 8) + 5;  { 640x480 1 page }
    EGALo = (EGA SHL 8) + 0;  { 640x200 16 color 4 page }
    EGAHi = (EGA SHL 8) + 1;  { 640x350 16 color 2 page }
    EGA64Lo = (EGA SHL 8) + 0;  { 640x200 16 color 1 page }
    EGA64Hi = (EGA SHL 8) + 1;  { 640x350 4 color  1 page }
    EGAMonoHi = (EGA SHL 8) + 3;  { 640x350 64K on card, 1 page; 256K on card, 2 page }
    HercMonoHi = (HercMono SHL 8) + 0;  { 720x348 2 page }
    ATT400C0 = (ATT400 SHL 8) + 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
    ATT400C1 = (ATT400 SHL 8) + 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
    ATT400C2 = (ATT400 SHL 8) + 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
    ATT400C3 = (ATT400 SHL 8) + 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
    ATT400Med = (ATT400 SHL 8) + 4;  { 640x200 1 page }
    ATT400Hi = (ATT400 SHL 8) + 5;  { 640x400 1 page }
    VGALo = (VGA SHL 8) + 0;  { 640x200 16 color 4 page }
    VGAMed = (VGA SHL 8) + 1;  { 640x350 16 color 2 page }
    VGAHi = (VGA SHL 8) + 2;  { 640x480 16 color 1 page }
    PC3270Hi = (PC3270 SHL 8) + 0;  { 720x350 1 page }
    IBM8514LO = (IBM8514 SHL 8) + 0;  { 640x480 256 colors }
    IBM8514HI = (IBM8514 SHL 8) + 1;  { 1024x768 256 colors }

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


Implementation

Uses
    SDL2,
Math;

Var
    { SDL2 graphics state }
    Window: PSDL_Window;
    Renderer: PSDL_Renderer;
    WindowWidth, WindowHeight: Integer;
    GraphInitialized: Boolean = False;

    { Current graphics state }
    CurrentX, CurrentY: Integer;
    CurrentColor: Word;
    CurrentBkColor: Word;
    CurrentLineStyle: Word;
    CurrentLinePattern: Word;
    CurrentLineThickness: Word;
    CurrentFillPattern: Word;
    CurrentFillColor: Word;

    { Text settings }
    CurrentFont: Word;
    CurrentTextDirection: Word;
    CurrentCharSize: Word;
    CurrentHorizJust: Word;
    CurrentVertJust: Word;

    { Viewport settings }
    ViewPortX1, ViewPortY1, ViewPortX2, ViewPortY2: Integer;
    ClipEnabled: Boolean;

    { Error state }
    LastGraphResult: Integer;


{ Color conversion from BGI to SDL2 }
Function BGIColorToSDL(Color: Word): TSDL_Color;
Begin
    Case Color Of
        Black:
        Begin
            Result.r := 0;
            Result.g := 0;
            Result.b := 0;
        End;
        Blue:
        Begin
            Result.r := 0;
            Result.g := 0;
            Result.b := 255;
        End;
        Green:
        Begin
            Result.r := 0;
            Result.g := 255;
            Result.b := 0;
        End;
        Cyan:
        Begin
            Result.r := 0;
            Result.g := 255;
            Result.b := 255;
        End;
        Red:
        Begin
            Result.r := 255;
            Result.g := 0;
            Result.b := 0;
        End;
        Magenta:
        Begin
            Result.r := 255;
            Result.g := 0;
            Result.b := 255;
        End;
        Brown:
        Begin
            Result.r := 165;
            Result.g := 42;
            Result.b := 42;
        End;
        LightGray:
        Begin
            Result.r := 192;
            Result.g := 192;
            Result.b := 192;
        End;
        DarkGray:
        Begin
            Result.r := 128;
            Result.g := 128;
            Result.b := 128;
        End;
        LightBlue:
        Begin
            Result.r := 173;
            Result.g := 216;
            Result.b := 230;
        End;
        LightGreen:
        Begin
            Result.r := 144;
            Result.g := 238;
            Result.b := 144;
        End;
        LightCyan:
        Begin
            Result.r := 224;
            Result.g := 255;
            Result.b := 255;
        End;
        LightRed:
        Begin
            Result.r := 255;
            Result.g := 182;
            Result.b := 193;
        End;
        LightMagenta:
        Begin
            Result.r := 255;
            Result.g := 174;
            Result.b := 201;
        End;
        Yellow:
        Begin
            Result.r := 255;
            Result.g := 255;
            Result.b := 0;
        End;
        White:
        Begin
            Result.r := 255;
            Result.g := 255;
            Result.b := 255;
        End;
    Else
    Begin
        Result.r := 255;
        Result.g := 255;
        Result.b := 255;
    End;
    End;
    Result.a := 255;
End;


Procedure FillRectWithPattern(x1, y1, x2, y2: integer; Pattern: word; Color: word);
Var
    FillColor, BkColor: TSDL_Color;
    i, j: Integer;
Begin
    If NOT GraphInitialized Then
        Exit;

    FillColor := BGIColorToSDL (Color);
    BkColor := BGIColorToSDL (CurrentBkColor);

    Case Pattern Of
        EmptyFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
        End;

        SolidFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            Bar (x1, y1, x2, y2);
        End;

        LineFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := y1 To y2 Do
                If (i - y1) MOD 4 = 0 Then
                    SDL_RenderDrawLine (Renderer, x1, i, x2, i);
        End;

        LtSlashFill, SlashFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := x1 To x2 Do
                For j := y1 To y2 Do
                    If (i - x1 + j - y1) MOD 8 = 0 Then
                        SDL_RenderDrawPoint (Renderer, i, j);
        End;

        BkSlashFill, LtBkSlashFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := x1 To x2 Do
                For j := y1 To y2 Do
                    If (i - x1 - j + y1) MOD 8 = 0 Then
                        SDL_RenderDrawPoint (Renderer, i, j);
        End;

        HatchFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := y1 To y2 Do
                If (i - y1) MOD 4 = 0 Then
                    SDL_RenderDrawLine (Renderer, x1, i, x2, i);
            For i := x1 To x2 Do
                If (i - x1) MOD 4 = 0 Then
                    SDL_RenderDrawLine (Renderer, i, y1, i, y2);
        End;

        XHatchFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := x1 To x2 Do
                For j := y1 To y2 Do
                    If ((i - x1 + j - y1) MOD 4 = 0) OR ((i - x1 - j + y1) MOD 4 = 0) Then
                        SDL_RenderDrawPoint (Renderer, i, j);
        End;

        WideDotFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := x1 To x2 Do
                For j := y1 To y2 Do
                    If ((i - x1) MOD 8 = 0) AND ((j - y1) MOD 8 = 0) Then
                        SDL_RenderDrawPoint (Renderer, i, j);
        End;

        CloseDotFill:
        Begin
            SDL_SetRenderDrawColor (Renderer, BkColor.r, BkColor.g, BkColor.b, BkColor.a);
            Bar (x1, y1, x2, y2);
            SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
            For i := x1 To x2 Do
                For j := y1 To y2 Do
                    If ((i - x1) MOD 4 = 0) AND ((j - y1) MOD 4 = 0) Then
                        SDL_RenderDrawPoint (Renderer, i, j);
        End;

    Else
    Begin
        SDL_SetRenderDrawColor (Renderer, FillColor.r, FillColor.g, FillColor.b, FillColor.a);
        Bar (x1, y1, x2, y2);
    End;
    End;

    SDL_RenderPresent (Renderer);
End;

{ *** high-level error handling *** }
Function GraphErrorMsg(ErrorCode: integer): String;
Begin
    Case ErrorCode Of
        grOk: GraphErrorMsg := 'No error';
        grNoInitGraph: GraphErrorMsg := 'Graphics not initialized';
        grNotDetected: GraphErrorMsg := 'Graphics hardware not detected';
        grFileNotFound: GraphErrorMsg := 'Device driver file not found';
        grInvalidDriver: GraphErrorMsg := 'Invalid device driver file';
        grNoLoadMem: GraphErrorMsg := 'Not enough memory to load driver';
        grNoScanMem: GraphErrorMsg := 'Out of memory in scan fill';
        grNoFloodMem: GraphErrorMsg := 'Out of memory in flood fill';
        grFontNotFound: GraphErrorMsg := 'Font file not found';
        grNoFontMem: GraphErrorMsg := 'Not enough memory to load font';
        grInvalidMode: GraphErrorMsg := 'Invalid graphics mode';
        grError: GraphErrorMsg := 'Graphics error';
        grIOerror: GraphErrorMsg := 'Graphics I/O error';
        grInvalidFont: GraphErrorMsg := 'Invalid font file';
        grInvalidFontNum: GraphErrorMsg := 'Invalid font number';
        grInvalidVersion: GraphErrorMsg := 'Invalid driver version';
    Else
        GraphErrorMsg := 'Unknown graphics error';
    End;
End;


Function GraphResult: integer;
Begin
    GraphResult := LastGraphResult;
    LastGraphResult := grOk;
End;

{ *** detection, initialization and crt mode routines *** }
Procedure InitGraph(Var GraphDriver: integer; Var GraphMode: integer; PathToDriver: String);
Begin
    LastGraphResult := grOk;

    If SDL_Init (SDL_INIT_VIDEO) < 0 Then
    Begin
        LastGraphResult := grError;
        exit;
    End;

    { Set default window size based on graphics mode }
    Case GraphMode Of
        VGAHi, EGAHi:
        Begin
            WindowWidth := 640;
            WindowHeight := 480;
        End;
        VGAMed:
        Begin
            WindowWidth := 640;
            WindowHeight := 350;
        End;
        VGALo:
        Begin
            WindowWidth := 640;
            WindowHeight := 200;
        End;
        MCGAHi:
        Begin
            WindowWidth := 640;
            WindowHeight := 480;
        End;
        MCGAMed:
        Begin
            WindowWidth := 640;
            WindowHeight := 200;
        End;
    Else
    Begin
        WindowWidth := 640;
        WindowHeight := 480;
    End; { Default VGA }
    End;

    Window := SDL_CreateWindow ('Pascal Graphics',
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        WindowWidth, WindowHeight, SDL_WINDOW_SHOWN);

    If Window = nil Then
    Begin
        LastGraphResult := grError;
        SDL_Quit ();
        exit;
    End;

    Renderer := SDL_CreateRenderer (Window, -1, SDL_RENDERER_ACCELERATED);
    If Renderer = nil Then
    Begin
        LastGraphResult := grError;
        SDL_DestroyWindow (Window);
        SDL_Quit ();
        exit;
    End;

    { Initialize state }
    GraphInitialized := True;
    GraphDriver := VGA;
    GraphMode := VGAHi;
    CurrentX  := 0;
    CurrentY  := 0;
    CurrentColor := White;
    CurrentBkColor := Black;
    CurrentLineStyle := SolidLn;
    CurrentLinePattern := 0;
    CurrentLineThickness := NormWidth;
    CurrentFillPattern := SolidFill;
    CurrentFillColor := White;
    CurrentFont := DefaultFont;
    CurrentTextDirection := HorizDir;
    CurrentCharSize := 1;
    CurrentHorizJust := LeftText;
    CurrentVertJust := TopText;
    ViewPortX1 := 0;
    ViewPortY1 := 0;
    ViewPortX2 := WindowWidth - 1;
    ViewPortY2 := WindowHeight - 1;
    ClipEnabled := False;

    { Clear screen to background color }
    SDL_SetRenderDrawColor (Renderer, 0, 0, 0, 255);
    SDL_RenderClear (Renderer);
    SDL_RenderPresent (Renderer);
End;


Procedure CloseGraph;
Begin
    If GraphInitialized Then
    Begin
        If Renderer <> nil Then
            SDL_DestroyRenderer (Renderer);
        If Window <> nil Then
            SDL_DestroyWindow (Window);
        SDL_Quit ();
        GraphInitialized := False;
        Window := nil;
        Renderer := nil;
    End;
End;


Procedure DetectGraph(Var GraphDriver, GraphMode: integer);
Begin
    GraphDriver := VGA;
    GraphMode := VGAHi;
    LastGraphResult := grOk;
End;


Function GetDriverName: string;
Begin
    GetDriverName := 'SDL2 Graphics Driver';
End;


Function GetGraphMode: integer;
Begin
    If GraphInitialized Then
        GetGraphMode := VGAHi
    Else
        GetGraphMode := 0;
End;


Procedure SetGraphMode(Mode: integer);
Begin
    If NOT GraphInitialized Then
    Begin
        LastGraphResult := grNoInitGraph;
        Exit;
    End;
    LastGraphResult := grOk;
End;


Function GetMaxX: integer;
Begin
    GetMaxX := WindowWidth - 1;
End;


Function GetMaxY: integer;
Begin
    GetMaxY := WindowHeight - 1;
End;


Function GetX: integer;
Begin
    GetX := CurrentX;
End;


Function GetY: integer;
Begin
    GetY := CurrentY;
End;


Procedure MoveTo(X, Y: integer);
Begin
    CurrentX := X;
    CurrentY := Y;
End;


Procedure MoveRel(Dx, Dy: integer);
Begin
    CurrentX := CurrentX + Dx;
    CurrentY := CurrentY + Dy;
End;


Procedure PutPixel(X, Y: integer; Pixel: word);
Var
    Color: TSDL_Color;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (Pixel);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);
    SDL_RenderDrawPoint (Renderer, X, Y);
    SDL_RenderPresent (Renderer);
End;


Function GetPixel(X, Y: integer): word;
Begin
    If NOT GraphInitialized Then
    Begin
        GetPixel := 0;
        Exit;
    End;
    GetPixel := 0;
End;


Procedure Line(x1, y1, x2, y2: integer);
Var
    Color: TSDL_Color;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);
    SDL_RenderDrawLine (Renderer, x1, y1, x2, y2);
    SDL_RenderPresent (Renderer);
    CurrentX := x2;
    CurrentY := y2;
End;


Procedure LineTo(X, Y: integer);
Begin
    Line (CurrentX, CurrentY, X, Y);
End;


Procedure LineRel(Dx, Dy: integer);
Begin
    Line (CurrentX, CurrentY, CurrentX + Dx, CurrentY + Dy);
End;


Procedure Rectangle(x1, y1, x2, y2: integer);
Var
    Color: TSDL_Color;
    Rect:  TSDL_Rect;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

    Rect.x := x1;
    Rect.y := y1;
    Rect.w := x2 - x1 + 1;
    Rect.h := y2 - y1 + 1;

    SDL_RenderDrawRect (Renderer, @Rect);
    SDL_RenderPresent (Renderer);
End;


Procedure Bar(x1, y1, x2, y2: integer);
Begin
    FillRectWithPattern (x1, y1, x2, y2, CurrentFillPattern, CurrentFillColor);
End;


Procedure Bar3D(x1, y1, x2, y2: integer; Depth: word; Top: boolean);
Begin
    If NOT GraphInitialized Then
        Exit;

    { Draw main filled rectangle }
    FillRectWithPattern (x1, y1, x2, y2, CurrentFillPattern, CurrentFillColor);

    { Draw 3D effect if depth > 0 }
    If Depth > 0 Then
    Begin
        { Right side }
        FillRectWithPattern (x2 + 1, y1 - Depth, x2 + Depth, y2 + Depth, CurrentFillPattern, CurrentColor);

        { Top side (if enabled) }
        If Top Then
            FillRectWithPattern (x1, y1 - Depth, x2 + Depth, y1 - 1, CurrentFillPattern, CurrentColor);
    End;
End;


Procedure Circle(X, Y: integer; Radius: word);
Var
    Color: TSDL_Color;
    i: Integer;
    xx, yy: Integer;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

    { Bresenham circle algorithm }
    i := 0;
    xx := Radius;
    yy := 0;

    While xx >= yy Do
    Begin
        SDL_RenderDrawPoint (Renderer, X + xx, Y + yy);
        SDL_RenderDrawPoint (Renderer, X + yy, Y + xx);
        SDL_RenderDrawPoint (Renderer, X - yy, Y + xx);
        SDL_RenderDrawPoint (Renderer, X - xx, Y + yy);
        SDL_RenderDrawPoint (Renderer, X - xx, Y - yy);
        SDL_RenderDrawPoint (Renderer, X - yy, Y - xx);
        SDL_RenderDrawPoint (Renderer, X + yy, Y - xx);
        SDL_RenderDrawPoint (Renderer, X + xx, Y - yy);

        Inc (yy);
        i := i + 1 + 2 * yy;
        If i > 0 Then
        Begin
            Dec (xx);
            i := i - 2 * xx;
        End;
    End;

    SDL_RenderPresent (Renderer);
End;


Procedure SetColor(Color: word);
Begin
    CurrentColor := Color;
End;


Function GetColor: word;
Begin
    GetColor := CurrentColor;
End;


Procedure SetBkColor(ColorNum: word);
Begin
    CurrentBkColor := ColorNum;
End;


Function GetBkColor: word;
Begin
    GetBkColor := CurrentBkColor;
End;


Procedure ClearDevice;
Var
    Color: TSDL_Color;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentBkColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);
    SDL_RenderClear (Renderer);
    SDL_RenderPresent (Renderer);
End;


Procedure Arc(X, Y: integer; StAngle, EndAngle, Radius: word);
Var
    Color: TSDL_Color;
    Angle, RadAngle: Real;
    px, py, lastpx, lastpy: Integer;
    FirstPoint: Boolean;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

    { Draw arc using line segments }
    FirstPoint := True;
    Angle := StAngle;

    lastpx := 0;
    lastpy := 0;

    While True Do
    Begin
        RadAngle := Angle * Pi / 180.0;
        px := X + Round (Radius * Cos (RadAngle));
        py := Y - Round (Radius * Sin (RadAngle));

        If NOT FirstPoint Then
            SDL_RenderDrawLine (Renderer, lastpx, lastpy, px, py);

        lastpx := px;
        lastpy := py;
        FirstPoint := False;

        If Angle = EndAngle Then
            Break;

        Angle := Angle + 1;
        If Angle > 360 Then
            Angle := Angle - 360;
        If (StAngle < EndAngle) AND (Angle > EndAngle) Then
            Break;
        If (StAngle > EndAngle) AND (Angle > EndAngle) AND (Angle < StAngle) Then
            Break;
    End;

    SDL_RenderPresent (Renderer);
End;


Procedure Ellipse(X, Y: integer; StAngle, EndAngle: word; XRadius, YRadius: word);
Var
    Color: TSDL_Color;
    Angle, RadAngle: Real;
    px, py, lastpx, lastpy: Integer;
    FirstPoint: Boolean;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

    { Draw elliptical arc using line segments }
    FirstPoint := True;
    Angle := StAngle;

    lastpx := 0;
    lastpy := 0;

    While True Do
    Begin
        RadAngle := Angle * Pi / 180.0;
        px := X + Round (XRadius * Cos (RadAngle));
        py := Y - Round (YRadius * Sin (RadAngle));

        If NOT FirstPoint Then
            SDL_RenderDrawLine (Renderer, lastpx, lastpy, px, py);

        lastpx := px;
        lastpy := py;
        FirstPoint := False;

        If Angle = EndAngle Then
            Break;

        Angle := Angle + 1;
        If Angle > 360 Then
            Angle := Angle - 360;
        If (StAngle < EndAngle) AND (Angle > EndAngle) Then
            Break;
        If (StAngle > EndAngle) AND (Angle > EndAngle) AND (Angle < StAngle) Then
            Break;
    End;

    SDL_RenderPresent (Renderer);
End;


Procedure PieSlice(X, Y: integer; StAngle, EndAngle, Radius: word);
Var
    Color: TSDL_Color;
    Angle: Real;
    minX, maxX, minY, maxY: Integer;
    scanY, scanX: Integer;
Begin
    If NOT GraphInitialized Then
        Exit;

    { Calculate bounding box for the pie slice }
    minX := X - Radius;
    maxX := X + Radius;
    minY := Y - Radius;
    maxY := Y + Radius;

    { Scan-line fill the pie slice area }
    For scanY := minY To maxY Do
        For scanX := minX To maxX Do
            If (scanX - X) * (scanX - X) + (scanY - Y) * (scanY - Y) <= Radius * Radius Then
            Begin
                { Calculate angle for this point }
                If (scanX = X) AND (scanY = Y) Then
                    Angle := StAngle { Center point - use start angle }
                Else
                Begin
                    Angle := ArcTan2 (Y - scanY, scanX - X) * 180.0 / Pi;
                    If Angle < 0 Then
                        Angle := Angle + 360;
                End;

                { Check if angle is within pie slice range }
                If ((StAngle <= EndAngle) AND (Angle >= StAngle) AND (Angle <= EndAngle)) OR
                    ((StAngle > EndAngle) AND ((Angle >= StAngle) OR (Angle <= EndAngle))) Then
                Begin
                    Color := BGIColorToSDL (CurrentFillColor);
                    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

                    { Apply fill pattern }
                    Case CurrentFillPattern Of
                        EmptyFill: ; { No fill }
                        SolidFill: SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        LineFill: If scanY MOD 3 = 0 Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        LtSlashFill: If (scanX + scanY) MOD 4 = 0 Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        SlashFill: If (scanX + scanY) MOD 3 = 0 Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        BkSlashFill: If (scanX - scanY) MOD 3 = 0 Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        LtBkSlashFill: If (scanX - scanY) MOD 4 = 0 Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        HatchFill: If (scanY MOD 3 = 0) OR ((scanX + scanY) MOD 3 = 0) Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        XHatchFill: If ((scanX + scanY) MOD 3 = 0) OR ((scanX - scanY) MOD 3 = 0) Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        InterleaveFill: If ((scanX + scanY) MOD 2 = 0) Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        WideDotFill: If (scanX MOD 4 = 0) AND (scanY MOD 4 = 0) Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                        CloseDotFill: If (scanX MOD 2 = 0) AND (scanY MOD 2 = 0) Then
                                SDL_RenderDrawPoint (Renderer, scanX, scanY);
                    End;
                End;
            End{ Check if point is inside circle };

    SDL_RenderPresent (Renderer);
End;


Procedure SetViewPort(x1, y1, x2, y2: integer; Clip: boolean);
Var
    ClipRect: TSDL_Rect;
Begin
    ViewPortX1 := x1;
    ViewPortY1 := y1;
    ViewPortX2 := x2;
    ViewPortY2 := y2;
    ClipEnabled := Clip;

    If GraphInitialized Then
        If Clip Then
        Begin
            ClipRect.x := x1;
            ClipRect.y := y1;
            ClipRect.w := x2 - x1 + 1;
            ClipRect.h := y2 - y1 + 1;
            SDL_RenderSetClipRect (Renderer, @ClipRect);
        End
        Else
            SDL_RenderSetClipRect (Renderer, nil);
End;


Procedure GetViewSettings(Var ViewPort: ViewPortType);
Begin
    ViewPort.x1 := ViewPortX1;
    ViewPort.y1 := ViewPortY1;
    ViewPort.x2 := ViewPortX2;
    ViewPort.y2 := ViewPortY2;
    ViewPort.Clip := ClipEnabled;
End;


Procedure ClearViewPort;
Var
    Color: TSDL_Color;
    ViewRect: TSDL_Rect;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentBkColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

    ViewRect.x := ViewPortX1;
    ViewRect.y := ViewPortY1;
    ViewRect.w := ViewPortX2 - ViewPortX1 + 1;
    ViewRect.h := ViewPortY2 - ViewPortY1 + 1;

    SDL_RenderFillRect (Renderer, @ViewRect);
    SDL_RenderPresent (Renderer);
End;


Procedure SetLineStyle(LineStyle: word; Pattern: word; Thickness: word);
Begin
    CurrentLineStyle := LineStyle;
    CurrentLinePattern := Pattern;
    CurrentLineThickness := Thickness;
End;


Procedure GetLineSettings(Var LineInfo: LineSettingsType);
Begin
    LineInfo.LineStyle := CurrentLineStyle;
    LineInfo.Pattern := CurrentLinePattern;
    LineInfo.Thickness := CurrentLineThickness;
End;


Procedure SetFillStyle(Pattern: word; Color: word);
Begin
    CurrentFillPattern := Pattern;
    CurrentFillColor := Color;
End;


Procedure GetFillSettings(Var FillInfo: FillSettingsType);
Begin
    FillInfo.Pattern := CurrentFillPattern;
    FillInfo.Color := CurrentFillColor;
End;


Procedure DrawPoly(NumPoints: word; Var PolyPoints);
Type
    PointArray = Array[1..1000] Of PointType;
Var
    Points: ^PointArray;
    i: Word;
    Color: TSDL_Color;
Begin
    If NOT GraphInitialized OR (NumPoints < 2) Then
        Exit;

    Points := @PolyPoints;
    Color := BGIColorToSDL(CurrentColor);
    SDL_SetRenderDrawColor(Renderer, Color.r, Color.g, Color.b, Color.a);

    { Draw lines connecting all points }
    For i := 1 To NumPoints - 1 Do
        SDL_RenderDrawLine(Renderer, Points^[i].X, Points^[i].Y, Points^[i + 1].X, Points^[i + 1].Y);

    { Close the polygon by connecting last point to first }
    SDL_RenderDrawLine(Renderer, Points^[NumPoints].X, Points^[NumPoints].Y, Points^[1].X, Points^[1].Y);

    SDL_RenderPresent(Renderer);
End;


Procedure FillPoly(NumPoints: word; Var PolyPoints);
Type
    PointArray = Array[1..1000] Of PointType;
Var
    Points: ^PointArray;
    i, j, minY, maxY, scanY: Integer;
    intersections: Array[1..1000] Of Integer;
    intersectionCount: Integer;
    x1, y1, x2, y2: Integer;
    temp: Integer;
Begin
    If NOT GraphInitialized OR (NumPoints < 3) Then
        Exit;

    Points := @PolyPoints;

    { Find bounding box }
    minY := Points^[1].Y;
    maxY := Points^[1].Y;
    For i := 1 To NumPoints Do
    Begin
        If Points^[i].Y < minY Then minY := Points^[i].Y;
        If Points^[i].Y > maxY Then maxY := Points^[i].Y;
    End;

    { Scan-line fill algorithm }
    For scanY := minY To maxY Do
    Begin
        intersectionCount := 0;

        { Find intersections with polygon edges }
        For i := 1 To NumPoints Do
        Begin
            j := i + 1;
            If j > NumPoints Then j := 1;

            x1 := Points^[i].X;
            y1 := Points^[i].Y;
            x2 := Points^[j].X;
            y2 := Points^[j].Y;

            { Check if scan line intersects this edge }
            If ((y1 <= scanY) AND (y2 > scanY)) OR ((y2 <= scanY) AND (y1 > scanY)) Then
            Begin
                If y1 <> y2 Then
                Begin
                    Inc(intersectionCount);
                    intersections[intersectionCount] := x1 + Round((scanY - y1) * (x2 - x1) / (y2 - y1));
                End;
            End;
        End;

        { Sort intersections }
        For i := 1 To intersectionCount - 1 Do
            For j := i + 1 To intersectionCount Do
                If intersections[i] > intersections[j] Then
                Begin
                    temp := intersections[i];
                    intersections[i] := intersections[j];
                    intersections[j] := temp;
                End;

        { Fill between pairs of intersections }
        i := 1;
        While i < intersectionCount Do
        Begin
            FillRectWithPattern(intersections[i], scanY, intersections[i + 1] - 1, scanY, CurrentFillPattern, CurrentFillColor);
            Inc(i, 2);
        End;
    End;

    SDL_RenderPresent(Renderer);
End;

End.
