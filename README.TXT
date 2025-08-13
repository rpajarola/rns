 ______________________________________________________________________________    
 
 R H Y T H M I C S  ( N O T A T I O N   S Y S T E M )                         1
 ______________________________________________________________________________


 RHYTHMICS is first of all a program to notate rhythms played on drums and
 small-percussion instruments: for this purpose the symbol font PERC.FNT was
 created. Characteristic for the RHYTHMICS NOTATION SYSTEM is the possibility
 to edit notelines which give a direct picture of time and its structure:
 symbols or notes are shown at the moment when they occur in time - and in
 relation to a given beat.
 This notation system is for most percussive instruments the more adequate way
 to notate and read - and you do not have to know anything about staff notation
 and its theory.

 Other fonts are added for demonstration: PITC#C-G.FNT (+ PITCHC-G.FNT)
 which allow to notate in pitch notes. Also LETTER.FNTs and CYPHER.FNT
 There are other special fonts for different usages:
 DRUMSET.FNT, DOREMI.FNT, PENTATONIC.FNT, NATURAL.FNT, OCTAVE.FNT, 
 PITCHSTEPS.FNT, GUITARTAB.FNT, MRIDANGAM.FNT etc.
 All these fonts on special order; extra fonts can be designed on request.
 Printing needs a postscript printer or a postscript emulation.

 Version 2.0 uses the intern loudspeaker to make the input of symbols and notes
 audible immediately - lines, pages, buffers or whole files can be played in
 the same way - though no soundcard etc. is necessary to work with the program.

 Rhythmics 2.0 runs safest under DOS.
 
 ______________________________________________________________________________
 
 A.  Copy all files from the diskette to the harddisk    (or: type 'a:install')
 ______________________________________________________________________________

 1 - create the 'RNS' directory on your harddisk: [C:\>] md rns
     (or any other path, for example [C:\MUSIC>] md rns)

 2 - change to this directory: [C:\>] cd rns
     the path will show as [C:\RNS>]

 3 - put the RHYTHMICS diskette into drive A and type: xcopy a:*.* /s
     ['copy' is not enough!] (note down these commands for further procedure)

 4 - type: rns

 5 - if you have a DEMO-VERSION you cannot create other directories than the
     given DEMODIR. Follow the instructions on the screen - you will get to
     the file TESTFILE.RNS. This file can be saved normally - all other files
     will be set on 'read only'.

 6 - if you are a licensed user, take some time to think about the directory-
     and file structure. Further SUBDIRECTORIES can NOT be opened, but you can
     have as many directories and files as you wish, and the program accepts
     as well directories with endings (for example 12345678.123)!

 7 - Do NOT start RHYTHMICS from the diskette (error message only)!


 ______________________________________________________________________________


 ______________________________________________________________________________
 
 B.  The Main Menu                                                            2
 ______________________________________________________________________________

 1 - Control 'F - DirName\ Files' (top button) = active directory + filelist.

 2 - you can choose within the menu (AS IN ALL MENUS!) by
     a) typing the shortcut-letter,
     b) using the cursor keys up and down + [Enter] or by
     c) using the mouse and its left button.

 3 - Generally [Enter] (or shortcut key or mouseclick) activates a selection,
	       [Esc] ignores a selection or escapes from a menu (or file).
	       (Right mouse button = [Esc] as well.)
	       To escape from the main menu resp. from the program is possible
	       only by choosing 'Quit .... Q' by cursor, shortcut-key or mouse.

 4 - Activate 'D - Directories': the directory-list will occur on the right
     side. [Enter] will show you the FILELIST of the chosen directory. If you
     type a new directory name, the program will ask you to confirm with 'Y'.

 5 - If you want the filelist of the active directory immediately choose
     'F - \ Files'. The last chosen file will be indicated in the title line.
     [Enter] opens the file. Eventually select another file from the list by
     cursor-keys or mouse. If you type a new name the program asks again for
     confirmation: in this case be aware that first the SETUP PAGE will be
     presented (usually with a brown background to warn you): layout this page
     as you want new pages in the file to look like - [F1] shows you a table of
     all the possible commands - then press [Esc]: the first page of the file
     will be presented. For later changes call up the setup page by [Alt]+[F9].

 6 - 'P - Page Layout' offers the possibility to install a DEFAULT PAGE for
     a certain DIRECTORY - whenever you open a new file in this directory the
     SETUP PAGE will look like this. Though 'Page Layout' is dependent on the
     active directory or the directory chosen immediately after escaping from
     the page layout menu.

 7 - This is almost the same  with the 'S - Symbol Fonts'. Activating one of
     the fonts and confirming with 'Y' will install this font in the active
     directory - but if you press [Esc] and then choose another directory, the
     font will permanently be installed there. Pressing [Esc] and then
     selecting 'Files' will install the chosen font temporaryly in the active
     file and will not overwrite the setup font for this directory.

 8 - (The menu 'Notelines .. N' is no more available in the new version:       
     it was in practice not really necessary. Notelines can be quickly defined
     in the [Shift]+[F3] menu, you can use Copy Line or even mark a special
     linesetting and write it to a buffer file: see Block [Shift]+[F8].)

 9 - With 'C - Colors' you get a list of prepared and tested color settings.
     The selection of a specific setting influences all directories.
     (If you need to have your own setting open the file 'myset.col' on the DOS
     Prompt with any editor and make your changes - or copy a setting you like
     into 'myset.col' and then make slight changes. The new colors will not
     show until you activate them by selecting again 'myset.col'!)
     'ptscreen.col' serves to get hardcopies of the full screen, 'ptpage.col'
     will show filepages only (install a printscreen utility first).

 ______________________________________________________________________________


 ______________________________________________________________________________
 
 C.  Learning how to use the program                                          3
 ______________________________________________________________________________

 1 - Use [F1] (=HELP) very often. The table shows all Hot-Key commands.
     Generally [Shift]+[F-Keys] are menus (except [Shift]+[F4]); [F-Keys] 
     (except [F6]) and [Ctrl]+[F-Keys] act immediately.

 2 - Activate the mouse menu with [F11] or by clicking with the left button
     ANYWHERE in the STATUS FIELD at the bottom of the active filepage.
     This mouse menu shows again the upper part of the [F1] helptable with
     abbreviations: 1 - 10 indicate the F-Keys; S, C and A stand for [Shift],
     [Ctrl] and [Alt] respectively.

 3 - Read through the file \DEMODIR\MANUAL.RNS within the program, more - or
     special things - are explained there in detail. Make it 'read only', then
     you can make tests, changes will not be saved (attrib +r manual.rns).
     IF YOU CAN'T MAKE IT without a printed manual, print out manual.rns
     (.eps-file [postscript], screenprint, or contact us to get a copy.

 ______________________________________________________________________________
 
 D.  Contacting RHYTHMICS
 ______________________________________________________________________________

 1 - If you have any problem, question or order write to:
     
     R H Y T H M I C S                  Tel/Fas +41 1 730 37 37
     S o n n e n h o f s t r . 1        e-mail: rhythmics@rhythmics.ch
     C H - 8 9 5 2  S c h l i e r e n   homepage: www.rhythmics.ch
     
   - to print an order sheet enter 'edit order.txt', then print this file. 


 2 - RHYTHMICS was sold for the equivalent of SFr. 180.- (incl. postage).
     Since 99 it has become FREEWARE, but all users must order it personally!

     Orders MUST contain: full name and address + tel.number (e-mail adr.)

     You will receive an e-mail (or diskette) with the full licensed program
     containing an internal serial number. Please be aware of copy rights.


 _______________________________________________________________________________
 
     
     You can print C:\RNS\README.TXT from DOS-Edit or from the Windows Editor.
     
 _______________________________________________________________________________




 
     RHYTHMICS percussion               +41 1 730 37 37
     Peo Oertli-Kassim                  peo@rhythmics.ch
     Sonnenhofstr. 1                    www.rhythmics.ch
     CH - 8952 Schlieren
 _______________________________________________________________________________

