18.7.93

Horizontale und vertikale Klammern
----------------------------------
Betrifft: Symbols.pas
	  Textunit.pas

Ende, Mitte und Anfang ge„ndert
Kleinstm”gliche Klammern gemacht
Mitte wirklich immer eingemittet
Damit der Klammeranfang sichtbar wird und der Mindestabstand einer vertikalen
Klammer eingehalten wird, springt der Cursor nach einem Vertikalklammeranfang
sofort auf die n„chste m”gliche Klammerendposition.


Filename
--------
Betrifft: Pageunit (Procedure PagPutBottomLine, mit {New} gekennzeichnet)
	  Der Filename wird jetzt richtig angezeigt.


SoundSpeed
----------
Betrifft: Grinout.pas
	  Imenuuni.pas
	  Graphmen.pas
	  SndUnit.pas
	  UserInt.pas
	  InitSc.pas
	  EditUnit.pas
	  PageUnit.pas

Speed-Angabe jetzt in Strokes/min. auf 3 Kommastellen (falls erwnscht)
+ Angabe der enstsprechenden Einstellungen in der Statuszeile
Texte im Sound options z.T. ge„ndert:
Speed (strokes per min.)
'Stroke equal to'  statt 'per'

F1
--
Betrifft: Helpunit.pas
	  Comunit.pas

Letzte Linie jetzt auch verfgbar.
Help Table vollst„ndig neu berarbeitet:
Beachte Umstellungen.
Neu dazu:
[<ÄÄÙ] ...
[Tab]
2-19 001-099
< >
Neue Features unter Shift + (Enter / Home / End / PageUp / PageDn)
Ctrl-F8 neu fr insert block
Ctll-Ins-Buffer sollte nur noch mit Ctrl-Del (Block) gefllt werden k”nnen:
ergibt noch einen Buffer mehr.
Anpassungen in der Function ComSpecGrant vorgenommen.


Hauptmenu & Filemenu, Fontmenu, Colorsmenu
------------------------------------------
Betrifft Userint.pas
	 Dispmenu.pas
	 Imenuuni.pas

Rahmen geht bis auf unterste Zeile.
Der Rahmen des Dir-/Filemenus wird von Anfang an angezeigt.
Der Cursor erscheint nicht mehr in Haupt- und Untermenus, nachdem man 1x
das Default Page Setup angew„hlt hat!


Insert/Delete/Neuer NL-Character
--------------------------------
Betrifft: Noteunit.pas
	  Comunit.pas

Er macht jetzt keinen Pagerefresh mehr, sondern refresht nur noch 10 Zeilen
darber und 7 darunter, und nur so breit wie n”tig + Sicherheitsstreifen.

********************************************************************************

21.7.93

[F1] = HELP	erscheint jetzt wieder auf jeder Seite (dank Grossmutter-Test)
		pageunit.pas

Hauptmenu-Texte vereinfacht, Anpassungen im
		userint.pas
		imenuuni.pas

Help Table	'Sound check' in 'Sound play' ge„ndert
		einerseits auf Grund des Grossmutter-Tests
		andererseits soll 'Sound check' die Bedeutung
		to check the sound quality haben, was ja nicht gemeint ist ...

'replace ?'     Press ...
		gleicher Text wie bei PgDn on last page
		Deshalb ge„ndert, bis diese Anpassung richtig ist.

Hintline	bei Eingabe-Menus z.B. 1..64 auf 1 - 64 ge„ndert


22.7.93

F1 Tabelle	zeigt immer alles an, auch wenn auf der Setup-Page oder Default-
		page.
		Diese in diesen beiden F„llen nicht m”glichen Eingaben, sollten
		sonst wenigstens in einer schw„cheren Farbe erscheinen.
		Fr den Moment ist es besser, man sieht immer die gleiche Tabelle
		unserint.pas (alle 'if not setuppage in actedit' herausgenommen

Zeilenangabe	zeigt jetzt auch richtig an wenn auf einer ML auf Position
		01-09, hat vorher die Null nicht angezeigt, wie bei Textlinie
		Pageunit.pas (223)

print		HlpBottomLine auf y-4 gesetzt, damit
		printing, SETUP PAGE und DEFAULTPAGE weiter oben erscheint
		[F1] = HELP dafr jetzt in der linken unteren Ecke

		printing page ... war entsprechend zu lange
		auf 'printing ...' ver„ndert (sollte dennoch klar sein)

		Menu:
		act page in 'actual page' ver„ndert
		Zusatz bei 'Filename'
		Options:
		1 page 2 pages war vertauscht, ist jetzt richtig
		imenuuni.pas

		'.EPS' jetzt '.eps'
		prmunit.pas

		Bei 'File "xxxxx./xxxxxx.xxx" already exists, overwrite?
		/ in \ verwandelt, wir sind ja da nicht im UNIX !!
		Punkt nach dem Directory weggenommen.
		prmunit.pas

		im gleichen Atemzug:
		userint.pas
		Punkt nach Directory auch im Directory-Menu weggenommen

Low Memory ..	Meldung war zu lang
		auf ' Split page (memory!!) ' abge„ndert
		initsc. Function IniPritNote
