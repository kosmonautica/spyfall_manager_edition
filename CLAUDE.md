# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projekt-Überblick

**Spyfall: Manager Edition** — ein Kartenspiel auf Basis des Originals Spyfall, aber mit Firmen-Setting. Statt eines Spions gibt es einen Manager, der in einem Meeting landet, ohne zu wissen worum es geht, und es trotzdem vortäuschen muss.

Die Karten werden mit **Ruby und dem Squib-Gem** generiert. Aktuell wird nur die **deutschsprachige Version** gebaut (DE-Spalten der CSV).

## Karten generieren

Kartengenerierung ausschließlich über die Batch-Datei starten (Windows):

```
start_card_generation.bat
```

Das Skript:
1. Ruft `ruby card_generator.rb` auf → erzeugt Vorderseiten- und Rückseiten-PDF
2. Ruft PDFtk auf → erzeugt doppelseitiges PDF durch Shufflen der Seiten

Ausgabe in `output/`:
- `spyfall_manager_edition_frontsides.pdf`
- `spyfall_manager_edition_backsides.pdf`
- `spyfall_manager_edition_doublesided.pdf`

## Tests ausführen

```bash
ruby test/test_card_data.rb
```

Tests werden nach jeder Änderung an CSV oder Skripten ausgeführt.

## Datenstruktur

Alle Karteninhalte stehen in `card_data_front_sides.csv` (Semikolon-getrennt, UTF-8 mit BOM):

| Spalte | Bedeutung |
|---|---|
| `ScenarioNumber` | Szenario-ID (1, 2, 3, …) |
| `ScenarioNameDE` | Szenario-Name (Deutsch) — aktuell in Verwendung |
| `RoleNumber` | Rollen-Nummer innerhalb des Szenarios |
| `RoleNameDE` | Rollen-Name (Deutsch) — aktuell in Verwendung |
| `ScenarioNameEN` / `RoleNameEN` | Englische Version (für spätere EN-Edition) |
| `ScenarioImage` | Dateiname des Hintergrundbilds (liegt in `images/`) |

**Manager-Karten:** ScenarioNumber `99`, `RoleNameDE` leer. Die Anzahl der Manager-Karten (Zeilen mit 99) entspricht der Anzahl der regulären Szenarien, damit jedes Spiel genau einen Manager hat. Hintergrundbild: `background_managerDE.png`.

**Neues Szenario hinzufügen:**
1. Rollen-Zeilen in der CSV ergänzen (neue ScenarioNumber)
2. Eine weitere Zeile mit ScenarioNumber 99 ergänzen
3. Hintergrundbild in `images/` ablegen

## Karten-Layout

Standard-Pokerkarte im **Landscape-Format**: 88,9 × 63,5 mm → 1050 × 750 px bei 300 dpi.

**Vorderseite:**
- Hintergrundbild füllt die gesamte Karte
- Oben links: kleine Sepia-Box mit Szenario-Nummer
- Oben daneben: große Sepia-Box mit Szenario-Name (fett, Courier New)
- Unten links: Sepia-Box mit Rollen-Name (Courier New, kein Rahmen)
- Schriftfarbe schwarz auf Sepia-Ton (`#c8a882`) für gute Lesbarkeit

**Rückseite:** Alle Karten identisch — `images/backsideDE.png`

**Ausgabe:** PDFs auf DIN A4 (`210mm × 297mm`), Squib arrangiert die Karten automatisch mit Rand, Gap und Beschnitt.

## Datei-Übersicht

```
start_card_generation.bat  # Einziger Einstiegspunkt für Kartengenerierung (Windows)
card_generator.rb          # Ruby/Squib-Skript: erzeugt Vorder- und Rückseiten-PDF
layout.yml                 # Squib-Layout-Definitionen: alle Positionen, Größen, Farben, Fonts
card_data_front_sides.csv  # Kerndaten für alle Karten
test/test_card_data.rb     # Minitest-Suite (7 Tests)
images/                    # Alle Bilder (Hintergründe, Rückseite, Sketches)
output/                    # Generierte PDFs (nicht committen)
```

## Layout-System

Alle statischen Designwerte (Positionen, Größen, Farben, Fonts) stehen in `layout.yml` als benannte Squib-Layouts:

| Layout-Name | Beschreibung |
|---|---|
| `card_background` | Hintergrundbild, füllt die ganze Karte |
| `scenario_number_box` | Kleine Sepia-Box oben links (Szenario-Nummer) |
| `scenario_name_box` | Große Sepia-Box oben daneben (Szenario-Name) |
| `scenario_number_text` | Text in der Nummern-Box |
| `scenario_name_text` | Text in der Name-Box |
| `role_name_text` | Text in der Rollen-Box unten |

Die Rollen-Box selbst hat keine feste Layout-Definition, da ihre Position, Größe und Farbe kartenabhängig berechnet werden (dynamisch aus den CSV-Daten). Nur die festen Werte (`stroke_color`, `stroke_width`, `radius`) sind im Skript direkt gesetzt.

Squib lädt das Layout mit `Squib::Deck.new(layout: 'layout.yml')`. Einzelne Befehle referenzieren ein Layout mit `layout: :name`. Per-Karte-Werte im Ruby-Code überschreiben dabei die YAML-Defaults.

## Wichtige Konventionen

- Neue Szenarien als neue Zeilen in der CSV ergänzen — das Skript liest alle automatisch ein
- Manager-Karten haben ScenarioNumber 99 und leeres RoleNameDE
- Englische Spalten in der CSV werden befüllt, aber im Skript noch nicht verwendet
- Doppelseitiges PDF wird via PDFtk `shuffle` erzeugt, nicht direkt in Squib
- CSV muss UTF-8 mit BOM gespeichert werden (Excel-Standard für Windows)
