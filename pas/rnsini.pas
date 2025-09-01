{$I RNS.H}

Unit RnsIni;

Interface

{ The global configuration }
Type
    TRnsConfig = Record
        DataDir: String;        { Where to look for files }
	PickFile: String;	{ Last file loaded }
        ColorFile: String;   { The color schema }
        PSDir: String;       { Where to write .ps files when printing to file }
        BufDir: String;      { scratch dir for buffers }
    End;

Var
    RnsConfig: TRnsConfig;

{ Load global configuration from rns.ini }
Procedure RnsIniLoadConfig();

{ Save global configuration to rns.ini }
Procedure RnsIniSaveConfig();

{ Per directory setup.ini }
Type
    TRnsSetup = Record
        {Setup}
        NoteBlock: string;
        InsMusicLine: string;
        LineCount: integer;
        FontFile:  string;

        {Display}
	DispSpec: integer; {Non-printing marks: 1 = show, 2 = hide}
	DispGrid: integer; {Grids: 1 = show, 2 = hide, 3 = bottom line only}
	DispHidLines: integer; {Helplines: 1 = show, 2 = hide}
	DispCurs: integer; {Cursor: 1 = show, 2 = show+cross, 3 = hide}
        DispSlash: integer; {

        {Keyboard}
        ManSet: integer; {1 = normal, 2 = add all characters}
        CharSet: integer; {1 = normal, 2 = <alt>, normal, shift}
        BlankSet: integer; {1 = space is blank, 2 = space is komma}
	KbdSound: integer; {Play Sound: 1 = play while editing, 2 = off}

        {Print}
        PrFormat: integer; {1 = 1 page per sheet, 2 = 2 pages per sheet}
        PrDest: integer;
        PrfName: string;
        PrFile: integer; {1 = print to file, 2 = print to printer}
        PrDevice: string;

        {Sound}
        SndLength: integer; {Length per beat}
        SndLengthPer: integer; {Length per beat or line}
        SndPlayBeat: integer; {Play beat sounds or not}
	SndPlayPulse: integer; {Play pulse sounds or not: bit 0:',' bit 1:' '}
        SndChar: char; {?}
        SndBeatPitch: integer; {Beat sound pitch}
        SndBeatLength: integer; {Beat sound length}
        SndPulsePitch: integer; {Pulse sound pitch}
        SndPulseLength: integer; {Pulse sound length}
        SndLengthSpm: double; {Strokes Per Minute}
	SndAttr: integer; {saXXX}
	SndWarning: integer; {Warning sounds: 0:none, 1:end of line, 2:end of screen, 3:both}

        {Misc}
        CtrlEnterOfs: integer;
    End;

Var
    RnsSetup: TRnsSetup;

{ Load per directory setup from rns.ini }
Procedure RnsIniLoadSetup();

{ Save Per directory setup to rns.ini }
Procedure RnsIniSaveSetup();

Implementation

Uses
    IniFiles,
    SysUtils;

Const
    RnsConfigFilename = 'rns.ini';

Const
    RnsSetupFilename = 'setup.ini';


Procedure RnsIniLoadConfig();
Var
    rnsIniFile: TIniFile;
Begin
    rnsIniFile := TIniFile.Create (RnsConfigFilename);
    RnsConfig.DataDir := rnsIniFile.ReadString ('main', 'datadir', 'demodir');
    RnsConfig.PickFile := rnsIniFile.ReadString ('main', 'pickfile', 'manual.rns');
    RnsConfig.ColorFile := rnsIniFile.ReadString ('main', 'colorfile', 'colors.rns');
    RnsConfig.PSDir := rnsIniFile.ReadString ('main', 'psdir', 'psdir');
    RnsConfig.BufDir := rnsIniFile.ReadString ('main', 'bufdir', 'bufdir');
    rnsIniFile.Free ();

    If NOT DirectoryExists (RnsConfig.DataDir) Then
        CreateDir (RnsConfig.DataDir);
    If NOT DirectoryExists (RnsConfig.PSDir) Then
        CreateDir (RnsConfig.PSDir);
End;


Procedure RnsIniSaveConfig();
Var
    rnsIniFile: TIniFile;
Begin
    rnsIniFile := TIniFile.Create (RnsConfigFilename);
    rnsIniFile.WriteString ('main', 'datadir', RnsConfig.DataDir);
    rnsIniFile.WriteString ('main', 'pickfile', RnsConfig.DataDir);
    rnsIniFile.WriteString ('main', 'colorfile', RnsConfig.ColorFile);
    rnsIniFile.WriteString ('main', 'psdir', RnsConfig.PSDir);
    rnsIniFile.WriteString ('main', 'bufdir', RnsConfig.BufDir);
    rnsIniFile.Free ();
End;


Procedure RnsIniLoadSetup();
Var
    fileName: string;
    rnsIniFile: TIniFile;
    sndCharStr: string;
Begin
    fileName := ConcatPaths ([RnsConfig.DataDir, RnsSetupFilename]);
    If FileExists (fileName) Then
        rnsIniFile := TIniFile.Create (fileName)
    Else
        rnsIniFile := TIniFile.Create (RnsSetupFilename);

    RnsSetup.NoteBlock := rnsIniFile.ReadString ('setup', 'noteblock', '              1  480    4    1');
    RnsSetup.InsMusicLine := rnsIniFile.ReadString ('setup', 'insmusicline', 'N            4    0  480    4 %.1.');
    RnsSetup.LineCount := rnsIniFile.ReadInteger ('setup', 'linecount', 1);

    RnsSetup.FontFile := rnsIniFile.ReadString ('setup', 'fontfile', 'perc.fnt');

    RnsSetup.DispSpec := rnsIniFile.ReadInteger ('display', 'spec', 1);
    RnsSetup.DispGrid := rnsIniFile.ReadInteger ('display', 'grid', 3);
    RnsSetup.DispHidLines := rnsIniFile.ReadInteger ('display', 'hidlines', 1);
    RnsSetup.DispCurs := rnsIniFile.ReadInteger ('display', 'cursor', 1);
    RnsSetup.DispSlash := rnsIniFile.ReadInteger ('display', 'slash', 1);
    If RnsSetup.DispSlash < 1 Then
    RnsSetup.DispSlash:=1;

    RnsSetup.ManSet := rnsIniFile.ReadInteger ('keyboard', 'manset', 1);
    RnsSetup.CharSet := rnsIniFile.ReadInteger ('keyboard', 'charset', 1);
    RnsSetup.BlankSet := rnsIniFile.ReadInteger ('keyboard', 'blankset', 1);
    RnsSetup.KbdSound := rnsIniFile.ReadInteger ('keyboard', 'sound', 1);

    RnsSetup.PrFormat := rnsIniFile.ReadInteger ('print', 'format', 2);
    RnsSetup.PrDest := rnsIniFile.ReadInteger ('print', 'destination', 1);
    RnsSetup.PrfName := rnsIniFile.ReadString ('print', 'filename', 'xxxxxxxx.EPS');
    RnsSetup.PrFile := rnsIniFile.ReadInteger ('print', 'tofile', 1);
    RnsSetup.PrDevice := rnsIniFile.ReadString ('print', 'device', 'FILE');

    RnsSetup.SndLength := rnsIniFile.ReadInteger ('sound', 'length', 750);
    RnsSetup.SndLengthPer := rnsIniFile.ReadInteger ('sound', 'lengthper', 1);
    RnsSetup.SndPlayBeat := rnsIniFile.ReadInteger ('sound', 'playbeat', 2);
    RnsSetup.SndPlayPulse := rnsIniFile.ReadInteger ('sound', 'playpulse', 2);
    sndCharStr := rnsIniFile.ReadString ('sound', 'char', 'L');
    If Length (sndCharStr) <> 1 Then
        sndCharStr := 'L';
    RnsSetup.SndChar := sndCharStr[1];
    RnsSetup.SndBeatPitch := rnsIniFile.ReadInteger ('sound', 'beatpitch', 1760);
    RnsSetup.SndBeatLength := rnsIniFile.ReadInteger ('sound', 'beatlength', 10);
    RnsSetup.SndPulsePitch := rnsIniFile.ReadInteger ('sound', 'pulsepitch', 50);
    RnsSetup.SndPulselength := rnsIniFile.ReadInteger ('sound', 'pulselength', 10);
    RnsSetup.SndLengthSpm := rnsIniFile.ReadFloat ('sound', 'strokesperminute', 8.0);
    RnsSetup.SndAttr := rnsIniFile.ReadInteger ('sound', 'attr', 0);
    RnsSetup.SndWarning := rnsIniFile.ReadInteger ('sound', 'warning', 1);
    if RnsSetup.SndWarning < 1 Then
    RnsSetup.SndWarning := 1;

    RnsSetup.CtrlEnterOfs := rnsIniFile.ReadInteger ('misc', '', 2);
    If RnsSetup.CtrlEnterOfs = 0 Then
    RnsSetup.CtrlEnterOfs:=2;

    rnsIniFile.Free ();
End;


Procedure RnsIniSaveSetup();
Var
    rnsIniFile: TIniFile;
Begin
    rnsIniFile := TIniFile.Create (ConcatPaths ([RnsConfig.DataDir, RnsSetupFilename]));

    RnsIniFile.WriteString ('setup', 'noteblock', RnsSetup.NoteBlock);
    RnsIniFile.WriteString ('setup', 'insmusicline', RnsSetup.InsMusicLine);
    RnsInifile.WriteInteger ('setup', 'linecount', RnsSetup.LineCount);

    RnsInifile.WriteString ('setup', 'fontfile', RnsSetup.FontFile);

    RnsInifile.WriteInteger ('display', 'spec', RnsSetup.DispSpec);
    RnsInifile.WriteInteger ('display', 'grid', RnsSetup.DispGrid);
    RnsInifile.WriteInteger ('display', 'hidlines', RnsSetup.DispHidLines);
    RnsInifile.WriteInteger ('display', 'cursor', RnsSetup.DispCurs);
    RnsInifile.WriteInteger ('display', 'slash', RnsSetup.DispSlash);

    RnsInifile.WriteInteger ('keyboard', 'manset', RnsSetup.ManSet);
    RnsInifile.WriteInteger ('keyboard', 'charset', RnsSetup.CharSet);
    RnsInifile.WriteInteger ('keyboard', 'blankset', RnsSetup.BlankSet);
    RnsInifile.WriteInteger ('keyboard', 'sound', RnsSetup.KbdSound);

    RnsInifile.WriteInteger ('print', 'format', RnsSetup.PrFormat);
    RnsInifile.WriteInteger ('print', 'destination', RnsSetup.PrDest);
    RnsInifile.WriteString ('print', 'filename', RnsSetup.PrfName);
    RnsInifile.WriteInteger ('print', 'tofile', RnsSetup.PrFile);
    RnsInifile.WriteString ('print', 'device', RnsSetup.PrDevice);

    RnsInifile.WriteInteger ('sound', 'length', RnsSetup.SndLength);
    RnsInifile.WriteInteger ('sound', 'lengthper', RnsSetup.SndLengthPer);
    RnsInifile.WriteInteger ('sound', 'playbeat', RnsSetup.SndPlayBeat);
    RnsInifile.WriteInteger ('sound', 'playpulse', RnsSetup.SndPlayPulse);
    RnsInifile.WriteString ('sound', 'char', RnsSetup.sndChar);
    RnsInifile.WriteInteger ('sound', 'beatpitch', RnsSetup.SndBeatPitch);
    RnsInifile.WriteInteger ('sound', 'beatlength', RnsSetup.SndBeatLength);
    RnsInifile.WriteInteger ('sound', 'pulsepitch', RnsSetup.SndPulsePitch);
    RnsInifile.WriteInteger ('sound', 'pulselength', RnsSetup.SndPulselength);
    RnsInifile.WriteFloat ('sound', 'strokesperminute', RnsSetup.SndLengthSpm);
    RnsIniFile.WriteInteger('sound', 'attr', RnsSetup.SndAttr);
    RnsInifile.WriteInteger ('sound', 'warning', RnsSetup.SndWarning);

    RnsInifile.WriteInteger ('misc', '', RnsSetup.CtrlEnterOfs);
    rnsIniFile.Free ();
End;

End.
