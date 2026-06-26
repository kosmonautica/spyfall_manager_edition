@echo off
rem Card generation: front sides, back sides and double-sided PDF in one step.
rem PDFtk shuffles pages alternating (F1 B1 F2 B2 ...) for duplex printing.
rem Back sides are saved with rtl:true in Squib so card positions are mirrored
rem horizontally -- this ensures front and back sides align correctly when
rem printing duplex (flip on long edge) on a portrait A4 sheet with landscape cards.
rem
rem Usage:
rem   start_card_generation.bat          -> both languages (DE + EN)
rem   start_card_generation.bat DE       -> German only
rem   start_card_generation.bat EN       -> English only
rem   start_card_generation.bat both     -> both languages (explicit)

set LANG=%~1
if "%LANG%"=="" set LANG=both

echo [1/3] Generating card fronts and backs (%LANG%) ...
if /I "%LANG%"=="DE"   echo  -> Language: DE only
if /I "%LANG%"=="EN"   echo  -> Language: EN only
if /I "%LANG%"=="BOTH" echo  -> Languages: DE + EN
call ruby card_generator.rb %LANG%
if %errorlevel% neq 0 (
    echo ERROR: Card generation failed.
    echo Hint: If a PDF could not be written, make sure it is not open in a PDF viewer.
    pause
    exit /b 1
)

echo [2/3] Generating scenario overview sheet (%LANG%) ...
call ruby scenario_overview.rb %LANG%
if %errorlevel% neq 0 (
    echo ERROR: Scenario overview generation failed.
    echo Hint: If a PDF could not be written, make sure it is not open in a PDF viewer.
    pause
    exit /b 1
)

set PDFTK="C:\Program Files (x86)\PDFtk\bin\pdftk.exe"

if not exist %PDFTK% (
    echo ERROR: PDFtk not found at %PDFTK%
    echo Please install PDFtk: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
    pause
    exit /b 1
)

if /I "%LANG%"=="DE" goto doublesided_de
if /I "%LANG%"=="EN" goto doublesided_en
goto doublesided_both

:doublesided_de
echo [3/3] Assembling double-sided PDF for duplex printing (DE) ...
cd output
if exist spyfall_manager_edition_doublesided_DE.pdf del spyfall_manager_edition_doublesided_DE.pdf
call %PDFTK% A="spyfall_manager_edition_frontsides_DE.pdf" B="spyfall_manager_edition_backsides_DE.pdf" shuffle output "spyfall_manager_edition_doublesided_DE.pdf"
if %errorlevel% == 0 (echo Done! DE PDF created.) else (echo ERROR: Failed to create DE PDF. Check if the file is still open in a PDF viewer. & cd .. & pause & exit /b 1)
cd ..
goto end

:doublesided_en
echo [3/3] Assembling double-sided PDF for duplex printing (EN) ...
cd output
if exist spyfall_manager_edition_doublesided_EN.pdf del spyfall_manager_edition_doublesided_EN.pdf
call %PDFTK% A="spyfall_manager_edition_frontsides_EN.pdf" B="spyfall_manager_edition_backsides_EN.pdf" shuffle output "spyfall_manager_edition_doublesided_EN.pdf"
if %errorlevel% == 0 (echo Done! EN PDF created.) else (echo ERROR: Failed to create EN PDF. Check if the file is still open in a PDF viewer. & cd .. & pause & exit /b 1)
cd ..
goto end

:doublesided_both
if exist output\spyfall_manager_edition_doublesided_DE.pdf del output\spyfall_manager_edition_doublesided_DE.pdf
if exist output\spyfall_manager_edition_doublesided_EN.pdf del output\spyfall_manager_edition_doublesided_EN.pdf
cd output

echo [3/4] Assembling double-sided PDF for duplex printing (DE) ...
call %PDFTK% A="spyfall_manager_edition_frontsides_DE.pdf" B="spyfall_manager_edition_backsides_DE.pdf" shuffle output "spyfall_manager_edition_doublesided_DE.pdf"
if %errorlevel% neq 0 (echo ERROR: Failed to create DE PDF. Check if the file is still open in a PDF viewer. & cd .. & pause & exit /b 1)

echo [4/4] Assembling double-sided PDF for duplex printing (EN) ...
call %PDFTK% A="spyfall_manager_edition_frontsides_EN.pdf" B="spyfall_manager_edition_backsides_EN.pdf" shuffle output "spyfall_manager_edition_doublesided_EN.pdf"
if %errorlevel% neq 0 (echo ERROR: Failed to create EN PDF. Check if the file is still open in a PDF viewer. & cd .. & pause & exit /b 1)

cd ..
echo Done! DE + EN - 4 PDFs each created in output\

:end
