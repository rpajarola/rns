echo off
cls
echo	   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo	   ³   FB-MultiCopy 1.0 fr Windows	     ³
echo	   ³	  (c) 1991/92 by Frank Brall	     ³
echo	   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo:
echo:
IF %1a == a goto Error
IF %1 == c: goto weiter
IF %1 == C: goto weiter
IF %1 == d: goto weiter
IF %1 == D: goto weiter
IF %1 == e: goto weiter
IF %1 == E: goto weiter

:Error
echo	 Bitte starten Sie die Installation mit folgenden Parametern:
echo	 INSTALL d:
echo:
echo	 d:	  bezeichnet das logische Laufwerk (z.B. c:)
echo:
echo:
goto ende

:weiter
echo	 Die Installation erfolgt in dem Verzeichnis %1\FB-WCOPY
echo:
echo	 * Erzeugen des Unterverzeichnisses
md %1\FB-WCOPY
echo	 * Installation der Programme & Daten
copy *.* %1\FB-WCOPY\*.* > nul
%1
cd %1\FB-WCOPY

:ende
echo:
echo:
echo Um FB-MultiCopy von Windows aus starten zu k”nnen, installieren
echo Sie das Programm mit dem Programmmanager. N„heres dazu finden
echo Sie auch im Handbuch zu Windows!
echo Sie k”nnen jedoch auch einfach WINCOPY aufrufen, Windows wird
echo dann automatisch nachgeladen!
echo:
echo Beachten Sie unbedingt auch die Hinweise in der Datei
echo HANDBUCH.TXT. Diese Dokumentation kann mit PRINTANL
echo gedruckt werden!
