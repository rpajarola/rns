{$I RNS.H}
Unit Texts;
Interface

Const HntBufempty = 01;
    HntBufItself = 02;
    HntCopyLineToHeader = 03;
    HntDistanceToSmall = 04;
    HntSplitFirstPage = 05;
    HntIllegalData = 06;
    HntNotExist = 07;
    HntNotBlockFile = 08;
    HntFooterHalfPage = 09;
    HntNotAvailableSetup = 10;
    HntNotAvailableLayout = 11;
    HntNotAvailableHeader = 12;
    HntHeaderHalfPage = 13;
    HntIllegalFileName = 14;
    HntIncorrectNote = 15;
    HntLineEmpty = 16;
    HntOutOfView = 17;
    HntNoMarkedArea = 18;
    HntNoSearchText = 19;
    HntNotEnoughSpace = 20;
    HntNotFound = 21;
    HntFileAccesDenied = 22;
    HntOutOfRange = 23;
    HntSavingFile = 24;
    HntSavingLine = 25;
    HntTooManyChars = 26;
    HntUnmarkBlockFirst = 27;
    HntOnLastPage = 28;
    HntOutOfMemory = 29;
    HntDivNotPossible = 30;
    HntTooManyFiles = 31;
    HntNoFilesFound = 32;
    HntPrinterError = 33;
    HntCantPlayPart = 34;
    HntReadOnly = 35;
    HntHideBase = 35;
    Hntdispspec = $01;
    HntDispGrid = $02;
    Hntdisphidlines = $04;
    Hntdispcurs = $08;
    HntSlash = 51;
    HntDemoNewPage = 52;
    HntUnmarkPageFirst = 53;
    HntPageEmpty = 54;
    HntDemoNIL = 55;
    HntDemoBuf = 56;
    HntDemoCRCTestfile = 57;
    HntDemoCRC = 58;
    HntPrintToFileFinished = 59;
    HntPrintFinished = 60;
    HntEmptyBracket = 61;
    HntCloseBracketFirst = 62;
    HntOpenBracketFirst = 63;
Const HintTexts: Array[1..63] Of String[66] =

        { Maximal length=66 }
        {01}      (('Buffer empty'),                                         {22,25}
        {02}       ('Cannot move block in to itself'),                       {20,26}
        {03}       ('Cannot copy line into header or footer'),               {0}
        {04}       ('Distance too small'),                                   {36}
        {05}       ('Do not split on first or last page'),                   {16}
        {06}       ('File contains illegal data'),                           {02}
        {07}       ('File does not exist'),                                  {13}
        {08}       ('File not written by the write block command'),          {14}
        {09}       ('Footer must be smaller than half of pagelength'),       {09}
        {10}       ('Function not available during linepattern setup'),      {32}
        {11}       ('Function not available during page layout'),            {30}
        {12}       ('Function not available on header or footer'),           {28,31}
        {13}       ('Header must be smaller than half of pagelength'),       {08}
        {14}       ('Illegal filename'),                                     {23}
        {15}       ('Incorrect note - textline merge'),                      {21}
        {16}       ('Line empty'),                                           {35}
        {17}       ('Location out of range (adapt Resolution: [Shift]+[F3])'),{04}
        {18}       ('No marked area'),                                       {10,11,12}
        {19}       ('No search text available'),                             {07}
        {20}       ('Not enough space on page'),                             {18,19}
        {21}       ('Not found'),                                            {06}
        {22}       ('File access denied'),
        {23}       ('Out of Range'),                                         {0}
        {24}       ('Saving file'),                                          {34}
        {25}       ('Saving line to buffer'),                                {33}
        {26}       ('Too many characters on line'),                          {03}
        {27}       ('Unmark block first by [F8]'),                           {15,27,29}
        {28}       ('You are on the last page'),                             {17}
        {29}       ('Out of memory'),                                        {01}
        {30}       (''),                                                     {05}{Noteunit 311!}
        {31}       ('Too many files, cannot display all files'),
        {32}       ('No files found'),
        {33}       ('Printer error'),
        {34}       ('Cannot play part of line'),
        {35}       ('Read only, cannot save changes'),
        {36}    {1}   ('[Shift]+[F1] - hidden: Nonprintings'),
        {37}    {2}   ('[Shift]+[F1] - hidden: Grids'),
        {38}    {3}   ('[Shift]+[F1] - hidden: Nonprintings / Grids'),
        {39}    {4}   ('[Shift]+[F1] - hidden: Helplines'),
        {40}    {5}   ('[Shift]+[F1] - hidden: Nonprintings / Helplines'),
        {41}    {6}   ('[Shift]+[F1] - hidden: Grids / Helplines'),
        {42}    {7}   ('[Shift]+[F1] - hidden: Nonprintings / Grids / Helplines'),
        {43}    {8}   ('[Shift]+[F1] - hidden: Cursor'),
        {44}    {9}   ('[Shift]+[F1] - hidden: Nonprintings / Cursor'),
        {45}    {A}   ('[Shift]+[F1] - hidden: Grids / Cursor'),
        {46}    {B}   ('[Shift]+[F1] - hidden: Nonprintings / Grids / Cursor'),
        {47}    {C}   ('[Shift]+[F1] - hidden: Helplines / Cursor'),
        {48}    {D}   ('[Shift]+[F1] - hidden: Nonprintings / Helplines / Cursor'),
        {49}    {E}   ('[Shift]+[F1] - hidden: Grids / Helplines / Cursor'),
        {50}    {F}   ('[Shift]+[F1] - hidden: Nonprintings / Grids / Helplines / Cursor'),
        {51}       ('Nothing to play: [/] in the beginning = no sound'),
        {52}       ('Demoversion is limited to four pages'),
        {53}       ('Unmark page first by [F9]'),
        {54}       ('Page empty'),
        {55}       ('Demo version: cannot open this file'),
        {56}       ('Cannot use buffer files in demoversion'),
        {57}       ('Demoversion: TESTFILE.RNS has been changed, restoring previous one'),
        {58}       ('Demoversion: file has been changed, restore from original diskette'),
        {59}       ('Finished printing to file'),
        {60}       ('Finished printing'),
        {61}       ('Can''t make empty brackets'),
        {62}       ('Close open bracket first'),
        {63}       ('Open bracket first before closing it'));

Implementation

End.
