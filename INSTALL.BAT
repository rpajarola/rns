echo off
cls
echo:
echo зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
echo Ё                                                                             Ё
echo Ё              R H Y T H M I C S   N O T A T I O N   S Y S T E M              Ё
echo Ё                                                                             Ё
echo Ё              Version 2.0     (C) 1999 by Rhythmics CH - Zurich              Ё
echo Ё                                                                             Ё
echo юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
echo зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё      A:INSTALL                                                              Ё
echo Ё                                                                             Ё
echo Ё    - Creates Directory C:\RNS and Subdirectory C:\RNS\DEMODIR               Ё
echo Ё                                                                             Ё
echo Ё    - Installs Programs and Files (can take up to a minute)                  Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
echo зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
echo Ё                                                                             Ё
echo Ё    - Finally brings you to the file README.TXT: Please read it carefully!   Ё
echo Ё                                                                             Ё
echo юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
md C:\RNS
copy a:\install.bat C:\RNS\*.* > nul
xcopy a:\*.* C:\RNS\*.* /s > nul
copy a:\install.bat C:\RNS\DEMODIR\*.* > nul
C:
del C:\RNS\install.bat > nul
del C:\RNS\DEMODIR\install.bat > nul

rem attrib +r C:\RNS\1st-read.txt > nul
rem attrib +r C:\RNS\readme.txt > nul
rem attrib +r C:\RNS\readme.wri > nul
rem attrib +r C:\RNS\DEMODIR\manual.rns > nul
rem attrib +r C:\RNS\DEMODIR\demopitc.rns > nul
rem attrib +r C:\RNS\DEMODIR\perc-sys.rns > nul
rem attrib +r C:\RNS\DEMODIR\pitchsys.rns > nul
cd C:\RNS
cls
mouse > nul
cls
edit readme.txt
echo:
echo:
echo:
echo:
echo:
echo:
echo:
echo:  
echo:
echo:
echo                             R  H  Y  T  H  M  I  C  S  
echo:
echo:
echo:  
echo:
echo:
echo:  
echo:  
echo:  
echo:  
echo:  
echo:
echo:  
echo:  
rns
exit
echo:
echo зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
echo Ё                                                                             Ё
echo Ё              R H Y T H M I C S   N O T A T I O N   S Y S T E M              Ё
echo Ё                                                                             Ё
echo Ё              Version 2.0     (C) 1999 by Rhythmics CH - Zurich              Ё
echo Ё                                                                             Ё
echo юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
echo зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё    - To start RHYTHMICS from WINDOWS install it with the Program Manager    Ё
echo Ё                                                                             Ё
echo Ё    - To start RHYTHMICS from DOS type 'rns' and confirm with [Enter]        Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo Ё                                                                             Ё
echo юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
echo:
