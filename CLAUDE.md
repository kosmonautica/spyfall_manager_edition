# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Spyfall: Manager Edition** — a card game based on the original Spyfall, set in a corporate environment. Instead of a spy, there is a Manager who ends up in a meeting without knowing what it is about and has to pretend otherwise.

Cards are generated using **Ruby and the Squib gem**. Both a **German (DE)** and an **English (EN)** version are built by default.

## Generating Cards

Card generation is started exclusively via the batch file (Windows):

```
start_card_generation.bat [DE|EN|both]
```

Optional parameter: `DE`, `EN`, or `both` (default). Without a parameter, both languages are built.

The script:
1. Calls `ruby card_generator.rb [lang]` → generates front and back side PDFs per language
2. Calls PDFtk → creates a double-sided PDF per language by shuffling pages

**Duplex alignment:** Back side PDFs are generated with `rtl: true` in Squib, which mirrors the card layout horizontally. This ensures front and back sides align correctly when printing duplex (flip on long edge) on a portrait A4 sheet with landscape cards. No PDFtk rotation step is needed.

Output in `output/` (per language):
- `spyfall_manager_edition_frontsides_DE.pdf` / `_EN.pdf`
- `spyfall_manager_edition_backsides_DE.pdf` / `_EN.pdf`
- `spyfall_manager_edition_doublesided_DE.pdf` / `_EN.pdf`

## Running Tests

```bash
ruby test/test_card_data.rb
```

Tests are run after every change to CSV files or scripts.

## Data Structure

Card content is split across two CSV files:

**`card_data_front_sides.csv`** (semicolon-separated, UTF-8 with BOM):

| Column | Description |
|---|---|
| `ScenarioNumber` | Scenario ID (1, 2, 3, ...) |
| `ScenarioNameDE` | Scenario name (German) |
| `RoleNumber` | Role number within the scenario |
| `RoleNameDE` | Role name (German) |
| `ScenarioNameEN` / `RoleNameEN` | English version |
| `ScenarioImage` | Background image filename (located in `images/`) |

**`card_data_back_sides.csv`** (semicolon-separated, UTF-8 without BOM):

| Column | Description |
|---|---|
| `Language` | Language code (`DE` or `EN`) |
| `BacksideText` | Back side text (not printed on card currently, serves as reference) |
| `BacksideImage` | Back side image filename (located in `images/`) |

**Manager cards:** ScenarioNumber `99`, `RoleNameDE`/`RoleNameEN` empty. The number of Manager cards (rows with 99) matches the number of regular scenarios so each game has exactly one Manager. Background image: `background_managerDE.png`.

**Adding a new scenario:**
1. Add role rows to the CSV (new ScenarioNumber)
2. Add one more row with ScenarioNumber 99
3. Place a background image in `images/`

## Card Layout

Standard poker card in **landscape format**: 88.9 x 63.5 mm -> 1050 x 750 px at 300 dpi.

**Front side:**
- Background image fills the entire card
- Top left: small sepia box with scenario number
- Top next to it: large sepia box with scenario name (bold, Courier New)
- Bottom left: sepia box with role name (Courier New, no border)
- Black text on sepia tone (`#c8a882`) for good readability

**Back side:** All cards identical — image from `card_data_back_sides.csv` for the respective language (`backsideDE.png` / `backsideEN.png`). Saved with `rtl: true` for duplex alignment.

**Output:** PDFs on DIN A4 (`210mm x 297mm`), Squib automatically arranges cards with margin, gap, and trim.

## File Overview

```
start_card_generation.bat  # Entry point for card generation (Windows)
card_generator.rb          # Ruby/Squib script: generates front and back side PDFs
layout.yml                 # Squib layout definitions: positions, sizes, colors, fonts
card_data_front_sides.csv  # Front side data: scenarios and roles (DE + EN)
card_data_back_sides.csv   # Back side data: image and text per language (DE + EN)
test/test_card_data.rb     # Minitest suite (11 tests)
images/                    # All images (backgrounds, back sides, sketches, photos)
output/                    # Generated PDFs (do not commit)
```

## Layout System

All static design values (positions, sizes, colors, fonts) are stored in `layout.yml` as named Squib layouts:

| Layout name | Description |
|---|---|
| `card_background` | Background image, fills the entire card |
| `scenario_number_box` | Small sepia box top left (scenario number) |
| `scenario_name_box` | Large sepia box next to it (scenario name) |
| `scenario_number_text` | Text in the number box |
| `scenario_name_text` | Text in the name box |
| `role_name_text` | Text in the role box at the bottom |
| `backside_text` | Centered, rotated text on the back side |

The role box itself has no fixed layout definition because its position, size, and color are computed dynamically per card from the CSV data. Only the fixed values (`stroke_color`, `stroke_width`, `radius`) are set directly in the script.

**Back side text centering:** `backside_text` uses a reduced bounding box (800×300 px) centered around the card midpoint (525, 375) via `x: 125, y: 225`. This compensates for Squib rotating around the top-left anchor `(x, y)` rather than the box center — using the full card size (1050×750) would shift the rotated text off-center.

Squib loads the layout with `Squib::Deck.new(layout: 'layout.yml')`. Individual commands reference a layout with `layout: :name`. Per-card values in the Ruby code override the YAML defaults.

## Conventions

- Add new scenarios as new rows in the CSV — the script reads all rows automatically
- Manager cards have ScenarioNumber 99 and empty RoleName columns (DE + EN)
- Back side image and text are stored in `card_data_back_sides.csv`, not hardcoded
- Double-sided PDF is created via PDFtk `shuffle`, not directly in Squib
- Back sides are saved with `rtl: true` so card positions are mirrored -- required for duplex alignment
- `card_data_front_sides.csv` must be saved as UTF-8 with BOM (Windows Excel standard)
- `card_data_back_sides.csv` is saved as UTF-8 without BOM (not edited in Excel)
- To add a new language: add a row to `card_data_back_sides.csv`, place a back side image in `images/`, and add the corresponding columns to `card_data_front_sides.csv`
- All text files in the repository use LF line endings (enforced via `.gitattributes`); `.bat` files use CRLF
