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


Implementation

Uses
    SDL2;

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
Var
    Color: TSDL_Color;
    Rect:  TSDL_Rect;
Begin
    If NOT GraphInitialized Then
        Exit;

    Color := BGIColorToSDL (CurrentFillColor);
    SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

    Rect.x := x1;
    Rect.y := y1;
    Rect.w := x2 - x1 + 1;
    Rect.h := y2 - y1 + 1;

    SDL_RenderFillRect (Renderer, @Rect);
    SDL_RenderPresent (Renderer);
End;


Procedure Bar3D(x1, y1, x2, y2: integer; Depth: word; Top: boolean);
Var
    Color: TSDL_Color;
    MainRect, TopRect, SideRect: TSDL_Rect;
Begin
    If NOT GraphInitialized Then
        Exit;

    { Draw main filled rectangle }
    Bar (x1, y1, x2, y2);

    { Draw 3D effect if depth > 0 }
    If Depth > 0 Then
    Begin
        Color := BGIColorToSDL (CurrentColor);
        SDL_SetRenderDrawColor (Renderer, Color.r, Color.g, Color.b, Color.a);

        { Right side }
        SideRect.x := x2 + 1;
        SideRect.y := y1 - Depth;
        SideRect.w := Depth;
        SideRect.h := y2 - y1 + 1 + Depth;
        SDL_RenderFillRect (Renderer, @SideRect);

        { Top side (if enabled) }
        If Top Then
        Begin
            TopRect.x := x1;
            TopRect.y := y1 - Depth;
            TopRect.w := x2 - x1 + 1 + Depth;
            TopRect.h := Depth;
            SDL_RenderFillRect (Renderer, @TopRect);
        End;

        SDL_RenderPresent (Renderer);
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

End.
