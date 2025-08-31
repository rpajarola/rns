{$I RNS.H}

Unit Texts;

Interface

Const
    HntBufempty = 'Buffer empty';
    HntBufItself = 'Cannot move block in to itself';
    HntCopyLineToHeader = 'Cannot copy line into header or footer';
    HntDistanceToSmall = 'Distance too small';
    HntSplitFirstPage = 'Do not split on first or last page';
    HntIllegalData = 'File %s contains illegal data';
    HntNotExist = 'File %s does not exist';
    HntNotBlockFile = 'File %s not written by the write block command';
    HntFooterHalfPage = 'Footer must be smaller than half of pagelength';
    HntNotAvailableSetup = 'Function not available during linepattern setup';
    HntNotAvailableLayout = 'Function not available during page layout';
    HntNotAvailableHeader = 'Function not available on header or footer';
    HntHeaderHalfPage = 'Header must be smaller than half of pagelength';
    HntIllegalFileName = 'Illegal filename %s';
    HntIncorrectNote = 'Incorrect note - textline merge';
    HntLineEmpty = 'Line empty';
    HntOutOfView = 'Location out of range (adapt Resolution: [Shift]+[F3])';
    HntNoMarkedArea = 'No marked area';
    HntNoSearchText = 'No search text available';
    HntNotEnoughSpace = 'Not enough space on page';
    HntNotFound = '%s Not found';
    HntFileAccesDenied = 'File %s access denied';
    HntOutOfRange = 'Out of Range';
    HntSavingFile = 'Saving file';
    HntSavingLine = 'Saving line to buffer';
    HntTooManyChars = 'Too many characters on line';
    HntUnmarkBlockFirst = 'Unmark block first by [F8]';
    HntOnLastPage = 'You are on the last page';
    HntOutOfMemory = 'Out of memory';
    HntDivNotPossible = 'Division %d:%d not possible';
    HntTooManyFiles = 'Too many files, cannot display all files';
    HntNoFilesFound = 'No files found';
    HntPrinterError = 'Printer %s error';
    HntCantPlayPart = 'Cannot play part of line';
    HntReadOnly = 'Read only, cannot save changes';
    HntDisp = '[Shift]+[F1] - hidden: %s';
    HntSlash = 'Nothing to play: [/] in the beginning = no sound';
    HntUnmarkPageFirst = 'Unmark page first by [F9]';
    HntPageEmpty = 'Page empty';
    HntPrintToFileFinished = 'Finished printing to file %s';
    HntPrintFinished = 'Finished printing to %s';
    HntEmptyBracket = 'Can''t make empty brackets';
    HntCloseBracketFirst = 'Close open bracket first';
    HntOpenBracketFirst = 'Open bracket first before closing it';
    HntCannotCreateFile = 'Cannot create file %s';
    HntFontFileNotFound = 'Font file %s not found';
    HntCannotOpenFile = 'Cannot open file %s';
    HntCannotOpenTempFile = 'Cannot open temp file';
    HntCannotReadFile = 'Cannot read file %s';
    HntCannotWriteFile = 'Cannot write file %s';

Implementation

End.
