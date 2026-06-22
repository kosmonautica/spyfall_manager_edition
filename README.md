# Spyfall: Manager Edition

Ein Kartenspiel für Firmen-Settings, inspiriert vom Original **Spyfall**.

Statt eines Spions gibt es hier einen **Manager**, der in einem Meeting landet — ohne zu wissen, worum es geht. Er muss vortäuschen, perfekt im Bild zu sein, während die anderen Teilnehmenden versuchen herauszufinden, wer der Manager ist.

Das Spiel wurde gemeinschaftlich von einer Gruppe während des **Agile Coach Camp Germany im Juni 2026 in Röckersbach** entwickelt und playtestet.

---

## Spielprinzip

- Alle Spieler bekommen eine Karte mit einem Meeting-Szenario und ihrer Rolle darin
- **Ein Spieler** bekommt die Manager-Karte — er weiß nur, dass er der Manager ist, aber nicht, in welchem Meeting er sitzt
- Die anderen Spieler kennen das Szenario, aber nicht, wer der Manager ist
- Durch Fragen und Antworten versuchen alle, den Manager zu entlarven — und der Manager versucht, nicht aufzufliegen

---

## Szenarien (aktuelle Version)

| Nr. | Szenario |
|---|---|
| 1 | Daily Standup Meeting |
| 2 | Kündigungsgespräch |
| 3 | Firmenweihnachtsfeier |

---

## Karten selbst drucken

### Voraussetzungen

Die Kartengenerierung läuft aktuell **nur unter Windows**, da die Batch-Datei Windows-spezifisch ist.

#### 1. Ruby installieren

Ruby wird für die Kartengenerierung benötigt.

- Download: https://rubyinstaller.org/ (empfohlen: Ruby+Devkit, aktuelle Version)
- Bei der Installation "Add Ruby executables to your PATH" aktivieren
- Installation prüfen: `ruby --version` in der Kommandozeile

Danach das Squib-Gem installieren:

```
gem install squib
```

#### 2. PDFtk installieren

PDFtk wird benötigt, um das doppelseitige PDF zu erzeugen.

- Download: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
- Standard-Installationspfad: `C:\Program Files (x86)\PDFtk\bin\pdftk.exe`
- Falls PDFtk an einem anderen Ort installiert wird, den Pfad in `start_card_generation.bat` anpassen

### Karten generieren

Im Projektordner die Datei `start_card_generation.bat` doppelklicken oder in der Kommandozeile ausführen:

```
start_card_generation.bat
```

Die generierten PDFs landen im Ordner `output/`:

| Datei | Inhalt |
|---|---|
| `spyfall_manager_edition_frontsides.pdf` | Alle Vorderseiten auf DIN A4 |
| `spyfall_manager_edition_backsides.pdf` | Alle Rückseiten auf DIN A4 |
| `spyfall_manager_edition_doublesided.pdf` | Doppelseitig: Vorderseite + Rückseite alternierend |

### Drucken und Ausschneiden

Für doppelseitigen Druck das `_doublesided.pdf` verwenden: ungerade Seiten sind Vorderseiten, gerade Seiten die dazugehörigen Rückseiten. Im Drucker "doppelseitig, an der langen Kante" wählen.

---

## Neue Szenarien hinzufügen

1. `card_data_front_sides.csv` öffnen (UTF-8 mit BOM, Semikolon-getrennt)
2. Neue Zeilen für jede Rolle des Szenarios ergänzen (neue `ScenarioNumber`)
3. Eine weitere Zeile mit `ScenarioNumber` = `99` und leerem `RoleNameDE` hinzufügen (Manager-Karte)
4. Ein passendes Hintergrundbild in `images/` ablegen und in `ScenarioImage` eintragen
5. `start_card_generation.bat` ausführen

Das Skript liest alle CSV-Zeilen automatisch ein — keine Code-Änderung nötig.

---

## Projektstruktur

```
start_card_generation.bat  # Einziger Einstiegspunkt für Kartengenerierung
card_generator.rb          # Ruby/Squib-Skript
card_data_front_sides.csv  # Spielinhalte (Szenarien, Rollen, Bilder)
images/                    # Hintergrundbilder und Kartenrückseite
output/                    # Generierte PDFs (nicht im Repository)
test/                      # Automatisierte Tests
```

---

## Entwicklung

Das Spiel ist Open Source. Neue Szenarien, Übersetzungen und Verbesserungen sind willkommen.

Für eine englische Version sind die Spalten `ScenarioNameEN` und `RoleNameEN` in der CSV bereits vorbereitet, aber noch nicht aktiv genutzt.
