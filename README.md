# Meeting Impossible

You have no idea how you ended up in this meeting. You don't have the faintest idea what it's about. So far, nobody has noticed. Hopefully you'll figure out the purpose of the meeting before your colleagues expose you as completely clueless. Until then: good luck faking competence.

In this game, one player takes on exactly that role. This person ends up in a meeting without knowing which one it is — and has to pretend otherwise. The other players know the scenario but not who the clueless person is. Through questions and answers, everyone tries to expose the clueless person while the clueless tries to blend in and to guess the scenario.

The game was collaboratively created and playtested at the **Agile Coach Camp Germany, June 2026, Rückersbach** by Irina Tolliszus, Hannah Schlamann, Martin Halfen, Martin Luig, Patrick Lehrbach, Frank Link, Tobias Wilmeroth and Udo Wiegärtner.

| | |
|---|---|
| ![Cards](images/photo_printout_cards.jpg) | ![Pages](images/photo_printout_pages.jpg) |

---

## How to use
You can print the pre-generated PDFs, cut out the cards and start playing right away.

In case you want to modify the content or add scenarios, you can do so using the descriptions below.

---

## Download

Ready-to-print PDFs (duplex, DIN A4):

- [Meeting_Impossible_doublesided_DE.pdf](output/Meeting_Impossible_doublesided_DE.pdf) - German version
- [Meeting_Impossible_doublesided_EN.pdf](output/Meeting_Impossible_doublesided_EN.pdf) - English version

Print settings: **duplex, flip on long edge**. Odd pages = front sides, even pages = back sides.

Scenario overview sheet (DIN A4, single-sided) — place this on the table during the game so all players can see which scenarios are in play at a glance:

- [Meeting_Impossible_scenarios_DE.pdf](output/Meeting_Impossible_scenarios_DE.pdf) - German version
- [Meeting_Impossible_scenarios_EN.pdf](output/Meeting_Impossible_scenarios_EN.pdf) - English version

---

## Scenarios

| # | German | English |
|---|---|---|
| 1 | Daily Standup Meeting | Daily Scrum Meeting |
| 2 | Kündigungsgesprach | Layoff Meeting |
| 3 | Firmenweihnachtsfeier | Corporate Christmas Party |
| 4 | Aufsichtsratssitzung | Board Meeting |
| 5 | Kantinen-Mittagspause | Lunch Break |
| 6 | ISO-Audit | ISO Audit |
| 7 | Brandschutzübung | Fire Drill |

---

## How to Play

- All players receive a card showing a meeting scenario and their role in it
- **One player** receives the "You are the clueless person" card - they only know they are the cluesless, not which meeting they are in
- All other players know the scenario but not who the clueless person is
- Through questions and answers, players try to expose the clueless - and the clueless tries to blend in and to guess the scenario before being uncovered

---

## Generate Your Own Cards

You can download and print the pre-generated cards. In case you want to modify or generate your own cards, here are the steps to do so.

### Prerequisites

Card generation currently runs **on Windows only**, as the batch file is Windows-specific.

#### 1. Install Ruby

Ruby is required for card generation.

- Download: https://rubyinstaller.org/ (recommended: Ruby+Devkit, current version)
- During installation, enable "Add Ruby executables to your PATH"
- Verify installation: `ruby --version` in the command line

Then install the Squib gem:

```
gem install squib
```

#### 2. Install PDFtk

PDFtk is required to create the double-sided PDF and for the page-count tests.

- Download: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
- Default installation path: `C:\Program Files (x86)\PDFtk\bin\pdftk.exe`
- If PDFtk is installed elsewhere, update the path in `start_card_generation.bat`

### Generate Cards

Run `start_card_generation.bat` from the project folder by double-clicking it or via the command line:

```
start_card_generation.bat [DE|EN|both]
```

The language parameter is optional. Default is `both` (generates DE and EN versions).

Generated PDFs are placed in the `output/` folder:

| File | Contents |
|---|---|
| `Meeting_Impossible_frontsides_DE.pdf` / `_EN.pdf` | All front sides on DIN A4 |
| `Meeting_Impossible_backsides_DE.pdf` / `_EN.pdf` | All back sides on DIN A4 |
| `Meeting_Impossible_doublesided_DE.pdf` / `_EN.pdf` | Duplex: front and back alternating |
| `Meeting_Impossible_scenarios_DE.pdf` / `_EN.pdf` | Scenario overview sheet (DIN A4, single-sided) |

### Printing and Cutting

For duplex printing, use the `_doublesided` PDF: odd pages are front sides, even pages are the corresponding back sides. In your printer settings, select "duplex, flip on long edge".

The back side PDF is generated with a mirrored card layout (`rtl: true` in Squib) so that front and back sides align correctly after flipping.

> **Important after cutting:** The cards are printed scenario by scenario. After cutting, sort the cards into sets — one set per scenario. Each set must include exactly **one clueless person card**. The clueless person cards are printed at the end of the PDF and can be identified by their distinct background image (no role text). Add one clueless person card to each scenario set before playing.

---

## Renaming the Game

The game name is configured in `card_data_back_sides_and_misc.csv` — one entry per language in the `GameName` column. Changing it there is sufficient; no code changes are needed:

1. Open `card_data_back_sides_and_misc.csv`
2. Change `GameName` for DE and/or EN to the new name
3. Run `start_card_generation.bat` — the new name will appear on the back of every card and as the prefix of all generated PDFs (spaces replaced by underscores)

---

## Adding New Scenarios

1. Open `card_data_front_sides.csv` (UTF-8 with BOM, semicolon-separated)
2. Add new rows for each role in the scenario (new `ScenarioNumber`)
3. Add one more row with `ScenarioNumber` = `99` and empty `RoleNameDE`/`RoleNameEN` (clueless person card)
4. Place a matching background image in `images/` and reference it in `ScenarioImage`
5. Run `start_card_generation.bat`

The script reads all CSV rows automatically -- no code changes required.

For generating background images for new scenarios, see [Generating Background Images](#generating-background-images) below.

---

## Generating Background Images

Background images are generated with **ChatGPT Image 2**. All prompts are documented in [`image_prompts.md`](image_prompts.md), which has two parts:

- **Part 1** — the shared base prompt: art style, lighting, company setting, character descriptions, and composition rules. This part is identical for every image.
- **Part 2** — one entry per scenario, each with a `SCENE` and an `ABSURDITY` section describing what is happening and what the subtle surreal detail is.

To generate a background image for a new scenario:

1. Copy Part 1 from `image_prompts.md`
2. Replace the `SCENE` and `ABSURDITY` placeholders with your own scene description
3. Feed the complete prompt to ChatGPT Image 2
4. Save the result as a PNG (landscape, 930×630 px) in the `images/` folder
5. Reference the filename in the `ScenarioImage` column of `card_data_front_sides.csv`
6. Add the new prompt to Part 2 of `image_prompts.md` so all prompts stay documented together

---

## Project Structure

```
start_card_generation.bat          # Entry point for card generation (Windows)
card_generator.rb                  # Ruby/Squib script: front and back side PDFs
scenario_overview.rb               # Ruby/Squib script: scenario overview sheet
card_data_front_sides.csv          # Card content: scenarios and roles (DE + EN)
card_data_back_sides_and_misc.csv  # Back side content + misc texts per language
layout.yml                         # Squib layout definitions: positions, sizes, colors, fonts
image_prompts.md                   # AI prompts used to generate the background images
images/                            # Background images and card backs
output/                            # Generated PDFs
test/                              # Automated tests
```

---

## Development

Contributions are welcome - new scenarios, translations, and improvements. Both DE and EN columns are active in the CSV and both language versions are generated by default.

---

## Legal Notice

**Meeting Impossible** is an unofficial community variant and is not affiliated with or endorsed by the publisher of the original **Spyfall** game. All rights to the original game remain with their respective owners.

This variant is an independent fan work and makes no claim to the trademark or intellectual property of the original game.

---

## License

[![CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

**Meeting Impossible**
Created 2026 by Irina Tolliszus, Hannah Schlamann, Martin Halfen, Martin Luig, Patrick Lehrbach, Frank Link, Tobias Wilmeroth, Udo Wiegärtner

Licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).

You are free to:
- **Share** - copy and redistribute the material in any medium or format
- **Adapt** - remix, transform, and build upon the material

Under the following terms:
- **Attribution (BY)** - You must give appropriate credit and name the authors listed above as the source
- **NonCommercial (NC)** - You may not use the material for commercial purposes
- **ShareAlike (SA)** - If you remix or adapt the material, you must distribute your contribution under the same license
