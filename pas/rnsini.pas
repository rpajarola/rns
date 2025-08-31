{$I RNS.H}

Unit RnsIni;

Interface

{ The global configuration }
Type
    TRnsConfig = Record
        DataDir: String;        { Where to look for files }
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
    RnsConfig.DataDir := rnsIniFile.ReadString ('main', 'DataDir', 'demodir');
    RnsConfig.ColorFile := rnsIniFile.ReadString ('main', 'ColorFile', 'colors.rns');
    RnsConfig.PSDir := rnsIniFile.ReadString ('main', 'PSDir', 'psdir');
    RnsConfig.BufDir := rnsIniFile.ReadString ('main', 'BufDir', 'bufdir');
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
    rnsIniFile.WriteString ('main', 'DataDir', RnsConfig.DataDir);
    rnsIniFile.WriteString ('main', 'ColorFile', RnsConfig.ColorFile);
    rnsIniFile.WriteString ('main', 'PSDir', RnsConfig.PSDir);
    rnsIniFile.WriteString ('main', 'BufDir', RnsConfig.BufDir);
    rnsIniFile.Free ();
End;


Procedure RnsIniLoadSetup();
Var
    rnsIniFile: TIniFile;
Begin
    rnsIniFile := TIniFile.Create (RnsSetupFilename);
    {RnsSetup.Foo :=rnsIniFile.ReadString('main', 'DataDir', 'demodir');}
    rnsIniFile.Free ();
End;


Procedure RnsIniSaveSetup();
Var
    rnsIniFile: TIniFile;
Begin
    rnsIniFile := TIniFile.Create (RnsSetupFilename);
    {rnsIniFile.WriteString('main', 'BufDir', RnsConfig.BufDir);}
    rnsIniFile.Free ();
End;

End.
