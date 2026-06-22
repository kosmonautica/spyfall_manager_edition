@echo off
rem Kartengenerierung: Vorderseiten, Rueckseiten und Double-Sided in einem Schritt.
rem PDFtk shuffelt die Seiten alternierend (V1 R1 V2 R2 ...) fuer doppelseitigen Druck.

call ruby card_generator.rb
if %errorlevel% neq 0 (
    echo FEHLER bei der Kartengenerierung
    pause
    exit /b 1
)

set PDFTK="C:\Program Files (x86)\PDFtk\bin\pdftk.exe"

if not exist %PDFTK% (
    echo FEHLER: PDFtk nicht gefunden unter %PDFTK%
    echo Bitte PDFtk installieren: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
    pause
    exit /b 1
)

if exist output\spyfall_manager_edition_doublesided.pdf del output\spyfall_manager_edition_doublesided.pdf

%PDFTK% A="output\spyfall_manager_edition_frontsides.pdf" B="output\spyfall_manager_edition_backsides.pdf" shuffle output "output\spyfall_manager_edition_doublesided.pdf"

if %errorlevel% == 0 (
    echo Fertig! Alle 3 PDFs in output\ erstellt.
) else (
    echo FEHLER beim Erstellen von spyfall_manager_edition_doublesided.pdf
    pause
)
