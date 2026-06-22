require 'squib'
require 'csv'

# Pokerkarte Landscape: 88.9mm x 63.5mm @ 300dpi
CARD_WIDTH  = 1050
CARD_HEIGHT = 750
SEPIA       = '#c8a882'
PDF_OPTS    = { width: '210mm', height: '297mm', margin: '10mm', gap: '5mm', trim: '2mm' }

data = CSV.read('card_data_front_sides.csv', headers: true, col_sep: ';',
                encoding: 'bom|utf-8').reject { |row| row['ScenarioNumber'].nil? }

ROLE_BOX_MIN        = 200  # Mindestbreite der Rollenbox
ROLE_BOX_MAX        = 980  # Maximalbreite (Karte ist 1050px, 20px Rand links)
ROLE_BOX_PADDING    = 20   # Innenabstand links/rechts
ROLE_BOX_H_ONE_LINE = 60   # Höhe einzeilige Rollenbox
ROLE_BOX_H_TWO_LINE = 110  # Höhe zweizeilige Rollenbox
ROLE_CHARS_PER_LINE = 40   # Ab dieser Zeichenanzahl wird zweizeilig

front_cards = data.map do |row|
  role = row['RoleNameDE'] || ''
  two_lines  = role.length > ROLE_CHARS_PER_LINE
  box_height = role.empty? ? 0 : (two_lines ? ROLE_BOX_H_TWO_LINE : ROLE_BOX_H_ONE_LINE)
  box_width  = role.empty? ? 0 : ROLE_BOX_MAX
  {
    scenario_number: row['ScenarioNumber'],
    scenario_name:   row['ScenarioNameDE'],
    role_name:       role,
    role_width:      box_width,
    role_height:     box_height,
    has_role:        !role.empty?,
    image:           "images/#{row['ScenarioImage']}"
  }
end

n = front_cards.size

# Vorab löschen – Windows sperrt PDFs, die noch in einem Viewer geöffnet sind
%w[spyfall_manager_edition_frontsides.pdf spyfall_manager_edition_backsides.pdf].each do |f|
  path = "output/#{f}"
  File.delete(path) if File.exist?(path)
end

# Vorderseiten-PDF
Squib::Deck.new(cards: n, width: CARD_WIDTH, height: CARD_HEIGHT) do
  png file: front_cards.map { |c| c[:image] },
      x: 0, y: 0, width: CARD_WIDTH, height: CARD_HEIGHT

  rect x: 20, y: 20, width: 60, height: 60,
       fill_color: SEPIA, stroke_color: SEPIA, stroke_width: 0, radius: 4
  rect x: 90, y: 20, width: 940, height: 60,
       fill_color: SEPIA, stroke_color: SEPIA, stroke_width: 0, radius: 4
  rect x: 20,
       y:      front_cards.map { |c| CARD_HEIGHT - 20 - c[:role_height] },
       width:  front_cards.map { |c| c[:role_width] },
       height: front_cards.map { |c| c[:role_height] },
       fill_color:   front_cards.map { |c| c[:has_role] ? SEPIA : '#00000000' },
       stroke_color: SEPIA, stroke_width: 0, radius: 4

  text str: front_cards.map { |c| c[:scenario_number] },
       x: 20, y: 20, width: 60, height: 60,
       font: 'Courier New 10', color: 'black',
       align: 'center', valign: 'middle'

  text str: front_cards.map { |c| c[:scenario_name] },
       x: 100, y: 24, width: 920, height: 52,
       font: 'Courier New Bold 13', color: 'black',
       align: 'left', valign: 'middle', ellipsize: 'autoscale'

  text str: front_cards.map { |c| c[:role_name] },
       x: 30,
       y:      front_cards.map { |c| CARD_HEIGHT - 20 - c[:role_height] + 4 },
       width:  front_cards.map { |c| [c[:role_width] - ROLE_BOX_PADDING * 2, 0].max },
       height: front_cards.map { |c| [c[:role_height] - 8, 0].max },
       font: 'Courier New 9', color: 'black',
       align: 'left', valign: 'middle'

  save_pdf file: 'spyfall_manager_edition_frontsides.pdf', dir: 'output', **PDF_OPTS
end

# Rückseiten-PDF
Squib::Deck.new(cards: n, width: CARD_WIDTH, height: CARD_HEIGHT) do
  png file: 'images/backsideDE.png',
      x: 0, y: 0, width: CARD_WIDTH, height: CARD_HEIGHT
  save_pdf file: 'spyfall_manager_edition_backsides.pdf', dir: 'output', **PDF_OPTS
end

puts "Fertig! #{n} Karten → output/spyfall_manager_edition_frontsides.pdf + output/spyfall_manager_edition_backsides.pdf"
